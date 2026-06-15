import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepting = false;
  bool _rejecting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.acceptConsent();
    if (mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao registrar consentimento.')),
      );
    }
    if (mounted) setState(() => _accepting = false);
  }

  Future<void> _reject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Excluir conta?', style: TextStyle(color: AppColors.text)),
        content: const Text(
          'Se você não aceitar os termos, sua conta e todos os dados serão excluídos permanentemente.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Excluir conta'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _rejecting = true);
    final auth = context.read<AuthProvider>();
    await auth.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso')),
      body: _rejecting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tealDim,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.privacy_tip, color: AppColors.teal, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Proteção de Dados (LGPD)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ao utilizar o Reab_Ly, você autoriza o tratamento dos seus dados pessoais para as seguintes finalidades:',
                    style: TextStyle(fontSize: 14, color: AppColors.text, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _item('Registro e acompanhamento das sessões de reabilitação.'),
                  _item('Compartilhamento das informações com seu profissional de saúde.'),
                  _item('Geração de relatórios de progresso para avaliação clínica.'),
                  _item('Comunicação sobre sua evolução e lembretes de atividades.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Seus dados serão armazenados de forma segura e não serão compartilhados com terceiros sem sua autorização explícita. Você pode solicitar a exclusão dos seus dados a qualquer momento.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _accepting ? null : _accept,
                      child: _accepting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                          : const Text('ACEITAR TERMOS'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _rejecting ? null : _reject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: BorderSide(color: AppColors.red.withOpacity(0.4)),
                      ),
                      child: const Text('NÃO ACEITAR E SAIR'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _item(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check, size: 18, color: AppColors.teal),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textDim, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
