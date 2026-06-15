import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(user?.name[0].toUpperCase() ?? '?', style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Nome', user?.name ?? ''),
                  _row('Email', user?.email ?? ''),
                  _row('Telefone', user?.phoneNumber ?? ''),
                  _row('Tipo', user?.role == 'doctor' ? 'Profissional' : 'Paciente'),
                ],
              ),
            ),
          ),
          if (user?.doctor != null) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados do Profissional', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    _row('CREFITO', user!.doctor!.crefito),
                    _row('Especialidade', user.doctor!.specialty),
                  ],
                ),
              ),
            ),
          ],
          if (user?.patient != null) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados do Paciente', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    _row('Data de Nascimento', user!.patient!.birthDate),
                    _row('Condição Clínica', user.patient!.clinicalCondition ?? 'Não informada'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sair', style: TextStyle(fontSize: 16)),
              onPressed: () async {
                await auth.logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
