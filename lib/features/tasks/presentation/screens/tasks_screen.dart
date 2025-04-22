import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/subtask_repository_impl.dart';
import '../../cubit/task_cubit.dart';
import '../widgets/subtask_list.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _subtaskRepository = SubtaskRepositoryImpl();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      context.read<TaskCubit>().loadTasks();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<TaskModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Comprar víveres',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Comprar leche, pan y huevos',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                final task = TaskModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  isCompleted: false,
                  createdAt: DateTime.now(),
                  subtasks: [],
                );
                Navigator.pop(context, task);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      context.read<TaskCubit>().createTask(result);
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, List<TaskModel>>(
        builder: (context, tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No hay tareas'),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ExpansionTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    context.read<TaskCubit>().toggleTaskCompletion(task.id);
                  },
                ),
                children: [
                  SubtaskList(
                    taskId: task.id,
                    repository: _subtaskRepository,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
