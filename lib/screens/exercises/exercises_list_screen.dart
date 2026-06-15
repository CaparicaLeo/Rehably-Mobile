import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'exercise_form_screen.dart';

class ExercisesListScreen extends StatefulWidget {
  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  final _api = ApiService();
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _api.get('/exercises');
      final list = (data['data'] as List).map((j) => Exercise.fromJson(j as Map<String, dynamic>)).toList();
      setState(() { _exercises = list; _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Erro ao carregar exercícios'; _isLoading = false; });
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Excluir exercício?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
      ],
    ));
    if (confirm != true) return;
    try {
      await _api.delete('/exercises/$id');
      _loadExercises();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      floatingActionButton: auth.isDoctor
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseFormScreen()));
                _loadExercises();
              },
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _exercises.isEmpty
                  ? const Center(child: Text('Nenhum exercício encontrado'))
                  : RefreshIndicator(
                      onRefresh: _loadExercises,
                      child: ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (_, i) {
                          final e = _exercises[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(e.category != null ? Icons.fitness_center : Icons.video_label)),
                              title: Text(e.title),
                              subtitle: Text('${e.category ?? "Sem categoria"}${e.videoUrl != null ? " • Com vídeo" : ""}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (e.videoUrl != null)
                                    IconButton(
                                      icon: const Icon(Icons.play_circle, color: Colors.blue),
                                      onPressed: () => _showVideoDialog(e.videoUrl!),
                                    ),
                                  if (auth.isDoctor)
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _delete(e.id),
                                    ),
                                ],
                              ),
                              onTap: () => _showDetailDialog(e),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showVideoDialog(String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vídeo do Exercício'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_library, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(url, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _showDetailDialog(Exercise ex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ex.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ex.description != null) Text(ex.description!),
            if (ex.category != null) ...[
              const SizedBox(height: 8),
              Text('Categoria: ${ex.category}'),
            ],
            if (ex.videoUrl != null) ...[
              const SizedBox(height: 8),
              Text('Vídeo: ${ex.videoUrl}'),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }
}
