import 'package:flutter/material.dart';
import '../../data/models/subtask_model.dart';
import '../../data/repositories/subtask_repository.dart';

class SubtaskList extends StatefulWidget {
  final String taskId;
  final SubtaskRepository repository;

  const SubtaskList({
    super.key,
    required this.taskId,
    required this.repository,
  });

  @override
  State<SubtaskList> createState() => _SubtaskListState();
}

class _SubtaskListState extends State<SubtaskList> {
  List<SubtaskModel> _subtasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    setState(() => _isLoading = true);
    try {
      final subtasks =
          await widget.repository.getSubtasksForTask(widget.taskId);
      setState(() {
        _subtasks = subtasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSubtask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Subtarea'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Título de la subtarea',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final controller = context.findRenderObject() as TextField;
              Navigator.pop(context, controller.controller?.text);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      final subtask = SubtaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        isCompleted: false,
        parentTaskId: widget.taskId,
        createdAt: DateTime.now(),
      );

      await widget.repository.createSubtask(subtask);
      _loadSubtasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        ListTile(
          title: const Text('Subtareas'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSubtask,
          ),
        ),
        ..._subtasks.map((subtask) => CheckboxListTile(
              title: Text(subtask.title),
              value: subtask.isCompleted,
              onChanged: (value) async {
                await widget.repository.toggleSubtaskCompletion(subtask.id);
                _loadSubtasks();
              },
            )),
      ],
    );
  }
}
