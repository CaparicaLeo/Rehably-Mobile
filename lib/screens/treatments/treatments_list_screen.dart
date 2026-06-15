import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/treatment.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'treatment_detail_screen.dart';
import 'treatment_form_screen.dart';

class TreatmentsListScreen extends StatefulWidget {
  final String? patientId;
  const TreatmentsListScreen({super.key, this.patientId});

  @override
  State<TreatmentsListScreen> createState() => _TreatmentsListScreenState();
}

class _TreatmentsListScreenState extends State<TreatmentsListScreen> {
  final _api = ApiService();
  List<Treatment> _treatments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final path = widget.patientId != null
          ? '/patients/${widget.patientId}/treatments'
          : '/treatments';
      final data = await _api.get(path);
      final list = data is List
          ? data.map((j) => Treatment.fromJson(j as Map<String, dynamic>)).toList()
          : (data['data'] as List).map((j) => Treatment.fromJson(j as Map<String, dynamic>)).toList();
      setState(() { _treatments = list; _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Erro ao carregar tratamentos'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tratamentos')),
      floatingActionButton: auth.isDoctor
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const TreatmentFormScreen()));
                _loadTreatments();
              },
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _treatments.isEmpty
                  ? const Center(child: Text('Nenhum tratamento encontrado'))
                  : RefreshIndicator(
                      onRefresh: _loadTreatments,
                      child: ListView.builder(
                        itemCount: _treatments.length,
                        itemBuilder: (_, i) {
                          final t = _treatments[i];
                          final statusColors = {
                            'ongoing': Colors.green,
                            'completed': Colors.blue,
                            'cancelled': Colors.red,
                          };
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text(t.title),
                              subtitle: Text('${t.startDate}${t.endDate != null ? ' a ${t.endDate}' : ''}'),
                              trailing: Chip(
                                label: Text(
                                  t.status == 'ongoing' ? 'Em andamento'
                                      : t.status == 'completed' ? 'Concluído'
                                      : 'Cancelado',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: statusColors[t.status] ?? Colors.grey,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TreatmentDetailScreen(treatmentId: t.id)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
