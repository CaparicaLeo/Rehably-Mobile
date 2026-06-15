import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TreatmentFormScreen extends StatefulWidget {
  final String? treatmentId;
  const TreatmentFormScreen({super.key, this.treatmentId});

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _titleCtrl = TextEditingController();
  final _patientIdCtrl = TextEditingController();
  final _doctorIdCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  String _status = 'ongoing';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _patientIdCtrl.dispose();
    _doctorIdCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final body = <String, dynamic>{
      'patient_id': _patientIdCtrl.text.trim(),
      'doctor_id': _doctorIdCtrl.text.trim(),
      'title': _titleCtrl.text.trim(),
      'start_date': _startDateCtrl.text.trim(),
      'end_date': _endDateCtrl.text.trim().isEmpty ? null : _endDateCtrl.text.trim(),
      'status': _status,
    };
    try {
      if (widget.treatmentId != null) {
        await _api.put('/treatments/${widget.treatmentId}', body: body);
      } else {
        await _api.post('/treatments', body: body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.treatmentId != null ? 'Tratamento atualizado!' : 'Tratamento criado!')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.errors?.toString() ?? e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.treatmentId != null ? 'Editar Tratamento' : 'Novo Tratamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientIdCtrl,
                decoration: const InputDecoration(labelText: 'ID do Paciente', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Informe o ID do paciente' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorIdCtrl,
                decoration: const InputDecoration(labelText: 'ID do Profissional', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Informe o ID do profissional' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Data de Início',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe a data de início' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Data de Término (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'ongoing', child: Text('Em andamento')),
                  DropdownMenuItem(value: 'completed', child: Text('Concluído')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
