import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/api_service.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _api = ApiService();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _api.get('/patients');
      final list = (data as List).map((j) => Patient.fromJson(j as Map<String, dynamic>)).toList();
      setState(() { _patients = list; _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Erro ao carregar pacientes'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientFormScreen()));
          _loadPatients();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _patients.isEmpty
                  ? const Center(child: Text('Nenhum paciente encontrado'))
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      child: ListView.builder(
                        itemCount: _patients.length,
                        itemBuilder: (_, i) {
                          final p = _patients[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text(p.user?.name[0].toUpperCase() ?? '?')),
                            title: Text(p.user?.name ?? 'Paciente'),
                            subtitle: Text(p.email ?? ''),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patientId: p.id))),
                          );
                        },
                      ),
                    ),
    );
  }
}
