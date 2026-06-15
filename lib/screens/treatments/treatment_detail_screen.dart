import 'package:flutter/material.dart';
import '../../models/treatment.dart';
import '../../models/treatment_item.dart';
import '../../services/api_service.dart';
import 'treatment_form_screen.dart';
class TreatmentDetailScreen extends StatefulWidget {
  final String treatmentId;
  const TreatmentDetailScreen({super.key, required this.treatmentId});

  @override
  State<TreatmentDetailScreen> createState() => _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState extends State<TreatmentDetailScreen> {
  final _api = ApiService();
  Treatment? _treatment;
  List<TreatmentItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _api.get('/treatments/${widget.treatmentId}');
      final tData = data is Map && data.containsKey('data') ? data['data'] : data;
      _treatment = Treatment.fromJson(tData as Map<String, dynamic>);
      final itemsData = await _api.get('/treatments/${widget.treatmentId}/items');
      _items = (itemsData as List).map((j) => TreatmentItem.fromJson(j as Map<String, dynamic>)).toList();
      setState(() { _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Erro ao carregar tratamento'; _isLoading = false; });
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _api.delete('/treatment-items/$itemId');
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Excluir tratamento?'),
      content: const Text('Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
      ],
    ));
    if (confirm != true) return;
    try {
      await _api.delete('/treatments/${widget.treatmentId}');
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_treatment?.title ?? 'Tratamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TreatmentFormScreen(treatmentId: widget.treatmentId)),
              );
              _loadData();
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${_treatment?.status ?? ""}'),
                              const SizedBox(height: 8),
                              Text('Início: ${_treatment?.startDate ?? ""}'),
                              const SizedBox(height: 8),
                              Text('Término: ${_treatment?.endDate ?? "A definir"}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Itens do Tratamento', style: Theme.of(context).textTheme.titleMedium),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _showAddItemDialog(),
                          ),
                        ],
                      ),
                      if (_items.isEmpty)
                        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhum item cadastrado')))
                      else
                        ..._items.map((item) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text('Exercício: ${item.exerciseId}'),
                                subtitle: Text(
                                  '${item.sets != null ? '${item.sets} séries' : ''}'
                                  '${item.repetitions != null ? ' x ${item.repetitions} reps' : ''}'
                                  '${item.durationSeconds != null ? ' ${item.durationSeconds}s' : ''}'
                                  '${item.frequencyText != null ? ' - ${item.frequencyText}' : ''}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _deleteItem(item.id),
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }

  void _showAddItemDialog() {
    final formKey = GlobalKey<FormState>();
    final exerciseIdCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final isLoading = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (ctx) => ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (_, loading, __) => AlertDialog(
          title: const Text('Adicionar Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: exerciseIdCtrl,
                    decoration: const InputDecoration(labelText: 'ID do Exercício', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: setsCtrl,
                    decoration: const InputDecoration(labelText: 'Séries', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: repsCtrl,
                    decoration: const InputDecoration(labelText: 'Repetições', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: durationCtrl,
                    decoration: const InputDecoration(labelText: 'Duração (segundos)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: freqCtrl,
                    decoration: const InputDecoration(labelText: 'Frequência', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: loading ? null : () async {
                if (!formKey.currentState!.validate()) return;
                isLoading.value = true;
                try {
                  await _api.post('/treatments/${widget.treatmentId}/items', body: {
                    'exercise_id': exerciseIdCtrl.text.trim(),
                    if (setsCtrl.text.isNotEmpty) 'sets': int.parse(setsCtrl.text),
                    if (repsCtrl.text.isNotEmpty) 'repetitions': int.parse(repsCtrl.text),
                    if (durationCtrl.text.isNotEmpty) 'duration_seconds': int.parse(durationCtrl.text),
                    if (freqCtrl.text.isNotEmpty) 'frequency_text': freqCtrl.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                } finally {
                  isLoading.value = false;
                }
              },
              child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
