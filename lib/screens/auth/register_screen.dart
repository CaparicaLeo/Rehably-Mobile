import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' show AuthProvider;
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _crefitoController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _clinicalConditionController = TextEditingController();

  String _role = 'patient';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _crefitoController.dispose();
    _specialtyController.dispose();
    _birthDateController.dispose();
    _clinicalConditionController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'phone_number': _phoneController.text.trim(),
      'role': _role,
    };
    if (_role == 'doctor') {
      body['crefito'] = _crefitoController.text.trim();
      body['specialty'] = _specialtyController.text.trim();
    } else {
      body['birth_date'] = _birthDateController.text.trim();
      if (_clinicalConditionController.text.trim().isNotEmpty) {
        body['clinical_condition'] = _clinicalConditionController.text.trim();
      }
    }
    final auth = context.read<AuthProvider>();
    auth.clearError();
    try {
      await auth.register(body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso! Faça login.')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.errors?.toString() ?? e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o email';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a senha';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar Senha', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) {
                  if (v != _passwordController.text) return 'Senhas não conferem';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Tipo de cadastro:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'patient', label: Text('Paciente')),
                  ButtonSegment(value: 'doctor', label: Text('Profissional')),
                ],
                selected: {_role},
                onSelectionChanged: (v) => setState(() => _role = v.first),
              ),
              const SizedBox(height: 16),
              if (_role == 'doctor') ...[
                TextFormField(
                  controller: _crefitoController,
                  decoration: const InputDecoration(labelText: 'CREFITO', border: OutlineInputBorder()),
                  validator: (v) {
                    if (_role == 'doctor' && (v == null || v.isEmpty)) return 'Informe o CREFITO';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(labelText: 'Especialidade', border: OutlineInputBorder()),
                  validator: (v) {
                    if (_role == 'doctor' && (v == null || v.isEmpty)) return 'Informe a especialidade';
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                    border: OutlineInputBorder(),
                    hintText: 'YYYY-MM-DD',
                  ),
                  validator: (v) {
                    if (_role == 'patient' && (v == null || v.isEmpty)) return 'Informe a data de nascimento';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicalConditionController,
                  decoration: const InputDecoration(labelText: 'Condição Clínica (opcional)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
