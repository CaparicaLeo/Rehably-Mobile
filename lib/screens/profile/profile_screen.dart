import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final patient = user?.patient;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tealDim,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.teal.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  user?.name?.[0].toUpperCase() ?? '?',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.teal),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
          ),
          Center(
            child: Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dados Pessoais', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                _row('Telefone', user?.phoneNumber ?? '—'),
                _row('Tipo', user?.role == 'doctor' ? 'Profissional' : 'Paciente'),
              ],
            ),
          ),
          if (patient != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dados do Paciente', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  _row('Data de Nascimento', patient.birthDate),
                  _row('Condição Clínica', patient.clinicalCondition ?? 'Não informada'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sair'),
            onPressed: () async {
              await auth.logout();
            },
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
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDim))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.text))),
        ],
      ),
    );
  }
}
