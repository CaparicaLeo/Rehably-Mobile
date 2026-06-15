import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class DiaryListScreenPage extends StatefulWidget {
  const DiaryListScreenPage({super.key});

  @override
  State<DiaryListScreenPage> createState() => _DiaryListScreenPageState();
}

class _DiaryListScreenPageState extends State<DiaryListScreenPage> {
  final _api = ApiService();
  List<dynamic> _sessions = [];
  bool _loading = true;
  int _page = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/diary?page=$_page&per_page=20');
      if (data is Map && data['data'] is List) {
        _sessions = data['data'] as List;
        _lastPage = (data['last_page'] as int?) ?? 1;
      } else if (data is List) {
        _sessions = data;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    _page = 1;
    await _load();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _lastPage) return;
    setState(() => _loadingMore = true);
    _page++;
    try {
      final data = await _api.get('/diary?page=$_page&per_page=20');
      if (data is Map && data['data'] is List) {
        _sessions.addAll(data['data'] as List);
        _lastPage = (data['last_page'] as int?) ?? 1;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Sessões')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _sessions.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 40, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text('Nenhuma sessão registrada.', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length + (_page < _lastPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _sessions.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: _loadingMore
                                ? const CircularProgressIndicator(strokeWidth: 2)
                                : TextButton(
                                    onPressed: _loadMore,
                                    child: const Text('Carregar mais'),
                                  ),
                          ),
                        );
                      }
                      final s = _sessions[index];
                      final item = s['treatment_item'] as Map?;
                      final exercise = item?['exercise'] as Map?;
                      final title = exercise?['title'] as String? ?? 'Exercício';
                      final date = s['session_date'] as String? ?? '';
                      final pain = s['pain_level'] as int?;
                      final fatigue = s['fatigue_level'] as int?;
                      final difficulty = s['difficulty_level'] as int?;
                      final completed = s['completed'] as bool? ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.tealDim,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(date,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
                                ),
                                const Spacer(),
                                if (completed)
                                  const Icon(Icons.check_circle, size: 16, color: AppColors.green)
                                else
                                  const Icon(Icons.pending, size: 16, color: AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                            if (completed && (pain != null || fatigue != null || difficulty != null)) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (pain != null) _LevelChip(label: 'Dor', value: pain),
                                  if (fatigue != null) _LevelChip(label: 'Fadiga', value: fatigue),
                                  if (difficulty != null) _LevelChip(label: 'Dificuldade', value: difficulty),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final int value;
  const _LevelChip({required this.label, required this.value});

  Color get _color {
    if (value <= 2) return AppColors.green;
    if (value <= 3) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
    );
  }
}
