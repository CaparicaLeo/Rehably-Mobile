import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'patients/patients_list_screen.dart';
import 'treatments/treatments_list_screen.dart';
import 'exercises/exercises_list_screen.dart';
import 'addresses/addresses_list_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reab_Ly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(user?.name[0].toUpperCase() ?? '?')),
              title: Text(user?.name ?? ''),
              subtitle: Text(user?.email ?? ''),
              trailing: Chip(
                label: Text(user?.role == 'doctor' ? 'Profissional' : 'Paciente'),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ),
          const SizedBox(height: 8),
          if (auth.isDoctor) ...[
            _MenuCard(
              icon: Icons.people,
              title: 'Meus Pacientes',
              subtitle: 'Gerenciar pacientes',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientsListScreen())),
            ),
            _MenuCard(
              icon: Icons.medical_services,
              title: 'Tratamentos',
              subtitle: 'Gerenciar tratamentos',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TreatmentsListScreen())),
            ),
            _MenuCard(
              icon: Icons.fitness_center,
              title: 'Exercícios',
              subtitle: 'Gerenciar exercícios',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesListScreen())),
            ),
          ],
          if (auth.isPatient) ...[
            _MenuCard(
              icon: Icons.medical_services,
              title: 'Meus Tratamentos',
              subtitle: 'Visualizar tratamentos',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TreatmentsListScreen())),
            ),
            _MenuCard(
              icon: Icons.fitness_center,
              title: 'Exercícios',
              subtitle: 'Meus exercícios',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesListScreen())),
            ),
          ],
          _MenuCard(
            icon: Icons.location_on,
            title: 'Endereços',
            subtitle: 'Meus endereços',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesListScreen())),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
