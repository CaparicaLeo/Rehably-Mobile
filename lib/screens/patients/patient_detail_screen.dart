import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/api_service.dart';
import '../treatments/treatments_list_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _api = ApiService();
  Patient? _patient;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _api.get('/patients/${widget.patientId}');
      setState(() { _patient = Patient.fromJson(data as Map<String, dynamic>); _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Erro ao carregar paciente'; _isLoading = false; });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Excluir paciente?'),
      content: const Text('Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
      ],
    ));
    if (confirm != true) return;
    try {
      await _api.delete('/patients/${widget.patientId}');
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
        title: Text(_patient?.user?.name ?? 'Paciente'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nome: ${_patient!.user?.name ?? "-"}'),
                            const SizedBox(height: 8),
                            Text('Email: ${_patient!.email ?? "-"}'),
                            const SizedBox(height: 8),
                            Text('Telefone: ${_patient!.phoneNumber ?? "-"}'),
                            const SizedBox(height: 8),
                            Text('Data de Nascimento: ${_patient!.birthDate}'),
                            const SizedBox(height: 8),
                            Text('Condição Clínica: ${_patient!.clinicalCondition ?? "-"}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.medical_services),
                      label: const Text('Ver Tratamentos'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TreatmentsListScreen(patientId: widget.patientId),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
