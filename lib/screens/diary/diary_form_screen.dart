import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class DiaryFormScreen extends StatefulWidget {
  const DiaryFormScreen({super.key});

  @override
  State<DiaryFormScreen> createState() => _DiaryFormScreenState();
}

class _DiaryFormScreenState extends State<DiaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  List<Map<String, dynamic>> _items = [];
  String? _selectedItemId;
  int _pain = 1;
  int _fatigue = 1;
  int _difficulty = 1;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final data = await _api.get('/my/treatments');
      if (data is Map && data['data'] is List) {
        final treatments = data['data'] as List;
        for (final t in treatments) {
          if (t['items'] is List) {
            for (final item in t['items'] as List) {
              if (item is Map<String, dynamic>) {
                _items.add(item);
              }
            }
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um exercício.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _api.post('/diary', body: {
        'treatment_item_id': _selectedItemId,
        'session_date': today,
        'pain_level': _pain,
        'fatigue_level': _fatigue,
        'difficulty_level': _difficulty,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão registrada!'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao registrar sessão.')),
      );
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Sessão')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exercício realizado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedItemId,
                      items: _items.map((item) {
                        final exercise = item['exercise'] as Map?;
                        final title = exercise?['title'] as String? ?? 'Exercício';
                        return DropdownMenuItem<String>(
                          value: item['id'] as String?,
                          child: Text(title, style: const TextStyle(color: AppColors.text)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedItemId = v),
                      decoration: const InputDecoration(hintText: 'Selecione um exercício'),
                      style: const TextStyle(color: AppColors.text),
                      dropdownColor: AppColors.surface2,
                      validator: (v) => v == null ? 'Selecione um exercício' : null,
                    ),
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Nenhum exercício disponível. Consulte seu profissional.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ),
                    const SizedBox(height: 24),
                    _LevelSection(title: 'Nível de Dor', value: _pain, onChanged: (v) => setState(() => _pain = v), color: AppColors.red),
                    const SizedBox(height: 20),
                    _LevelSection(title: 'Nível de Fadiga', value: _fatigue, onChanged: (v) => setState(() => _fatigue = v), color: AppColors.amber),
                    const SizedBox(height: 20),
                    _LevelSection(title: 'Dificuldade de Execução', value: _difficulty, onChanged: (v) => setState(() => _difficulty = v), color: AppColors.blue),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                            : const Text('Salvar Sessão'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  const _LevelSection({required this.title, required this.value, required this.onChanged, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 4),
        const Text('1 = Mínima, 5 = Máxima', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final level = i + 1;
            final selected = level == value;
            return GestureDetector(
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.2) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
