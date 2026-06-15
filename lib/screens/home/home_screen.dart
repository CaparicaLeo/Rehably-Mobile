import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../diary/diary_form_screen.dart';
import '../diary/diary_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final patient = user?.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reab_Ly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Histórico',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryListScreenPage())),
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Greeting(name: user?.name),
            const SizedBox(height: 20),
            _TodayCta(patientId: patient?.id),
            const SizedBox(height: 16),
            _QuickStats(patientId: patient?.id),
            const SizedBox(height: 20),
            const Text('Últimas sessões', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 8),
            _RecentSessions(patientId: patient?.id),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryFormScreen())),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.bg,
        icon: const Icon(Icons.add),
        label: const Text('Nova Sessão'),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String? name;
  const _Greeting({this.name});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String get _today {
    final months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final d = DateTime.now();
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$_greeting,', style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
        Text(name?.split(' ')[0] ?? 'Paciente', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 4),
        Text(_today, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }
}

class _TodayCta extends StatelessWidget {
  final String? patientId;
  const _TodayCta({this.patientId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tealDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sessão de hoje', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 4),
                const Text('Registre seus níveis de dor, fadiga e dificuldade.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: AppColors.teal, size: 28),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatefulWidget {
  final String? patientId;
  const _QuickStats({this.patientId});
  @override
  State<_QuickStats> createState() => _QuickStatsState();
}

class _QuickStatsState extends State<_QuickStats> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ApiService();
    try {
      final end = DateTime.now().toIso8601String().split('T')[0];
      final start = DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
      final data = await api.get('/diary/stats?start_date=$start&end_date=$end');
      if (data is Map<String, dynamic>) {
        _stats = data;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    final total = _stats?['total_sessions'] ?? 0;
    final completed = _stats?['completed_sessions'] ?? 0;
    final rate = _stats?['adherence_rate'] ?? 0;
    final pain = _stats?['avg_pain'];

    return Row(
      children: [
        _StatCard(value: '$total', label: 'Sessões', color: AppColors.teal),
        const SizedBox(width: 8),
        _StatCard(value: '$completed', label: 'Concluídas', color: AppColors.green),
        const SizedBox(width: 8),
        _StatCard(value: '$rate%', label: 'Adesão', color: AppColors.blue),
        if (pain != null) ...[
          const SizedBox(width: 8),
          _StatCard(value: '${(pain as num).toStringAsFixed(1)}', label: 'Média Dor', color: AppColors.amber),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _RecentSessions extends StatefulWidget {
  final String? patientId;
  const _RecentSessions({this.patientId});
  @override
  State<_RecentSessions> createState() => _RecentSessionsState();
}

class _RecentSessionsState extends State<_RecentSessions> {
  List<dynamic> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ApiService();
    try {
      final data = await api.get('/diary?per_page=5');
      if (data is Map && data['data'] is List) {
        _sessions = data['data'] as List;
      } else if (data is List) {
        _sessions = data;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_note, size: 32, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('Nenhuma sessão registrada ainda.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }
    return Column(
      children: _sessions.map((s) {
        final item = s['treatment_item'] as Map?;
        final exercise = item?['exercise'] as Map?;
        final title = exercise?['title'] as String? ?? 'Exercício';
        final date = s['session_date'] as String? ?? '';
        final pain = s['pain_level'] as int?;
        final completed = s['completed'] as bool? ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (completed && pain != null)
                _LevelBadge(value: pain, color: pain <= 2 ? AppColors.green : (pain <= 3 ? AppColors.amber : AppColors.red), label: 'Dor'),
              if (!completed)
                const _LevelBadge(value: 0, color: AppColors.textMuted, label: 'Pendente'),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int value;
  final Color color;
  final String label;
  const _LevelBadge({required this.value, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label $value', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
