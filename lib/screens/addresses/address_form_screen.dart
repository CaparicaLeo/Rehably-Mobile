import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddressFormScreen extends StatefulWidget {
  final String? addressId;
  const AddressFormScreen({super.key, this.addressId});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _postalCodeCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _postalCodeCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _complementCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final body = <String, dynamic>{
      'user_id': _userIdCtrl.text.trim(),
      'postal_code': _postalCodeCtrl.text.trim(),
      'street': _streetCtrl.text.trim().isEmpty ? null : _streetCtrl.text.trim(),
      'number': _numberCtrl.text.trim(),
      'neighborhood': _neighborhoodCtrl.text.trim().isEmpty ? null : _neighborhoodCtrl.text.trim(),
      'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
      'complement': _complementCtrl.text.trim().isEmpty ? null : _complementCtrl.text.trim(),
    };
    try {
      if (widget.addressId != null) {
        await _api.put('/addresses/${widget.addressId}', body: body);
      } else {
        await _api.post('/addresses', body: body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.addressId != null ? 'Endereço atualizado!' : 'Endereço criado!')),
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
      appBar: AppBar(title: Text(widget.addressId != null ? 'Editar Endereço' : 'Novo Endereço')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(labelText: 'ID do Usuário', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Informe o ID do usuário' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postalCodeCtrl,
                decoration: const InputDecoration(labelText: 'CEP', border: OutlineInputBorder(), hintText: 'XXXXX-XXX'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o CEP' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberCtrl,
                decoration: const InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Informe o número' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetCtrl,
                decoration: const InputDecoration(labelText: 'Logradouro (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _neighborhoodCtrl,
                decoration: const InputDecoration(labelText: 'Bairro (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'Cidade (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateCtrl,
                decoration: const InputDecoration(labelText: 'Estado (opcional)', border: OutlineInputBorder(), hintText: 'SP'),
                maxLength: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complementCtrl,
                decoration: const InputDecoration(labelText: 'Complemento (opcional)', border: OutlineInputBorder()),
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
