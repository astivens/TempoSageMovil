import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/activity_model.dart';

import '../../data/repositories/activity_repository.dart';
import '../screens/create_activity_screen.dart';
import '../screens/edit_activity_screen.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final ActivityRepository _repository = ActivityRepository();
  final TextEditingController _searchController = TextEditingController();
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';
  String _selectedPriority = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _repository.getAllActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editActivity(ActivityModel activity) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditActivityScreen(
          activity: activity,
        ),
      ),
    );
    await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Activities',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateActivityScreen(),
                ),
              );
              _loadActivities(); // Reload activities after returning
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage all your scheduled activities and tasks',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    hintStyle: AppStyles.bodyMedium.copyWith(
                      color: AppColors.overlay0,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.overlay0),
                    filled: true,
                    fillColor: AppColors.surface0,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Category',
                        _selectedCategory,
                        ['Todos', 'Trabajo', 'Personal'],
                        (value) => setState(() => _selectedCategory = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Priority',
                        _selectedPriority,
                        ['Todas', 'Alta', 'Media', 'Baja'],
                        (value) => setState(() => _selectedPriority = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Activities List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      return _buildActivityCard(activity);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        style: AppStyles.bodyMedium,
        dropdownColor: AppColors.surface0,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.overlay0),
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _getPriorityColor(activity.priority),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          activity.title,
          style: AppStyles.bodyLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Today, ${TimeOfDay.fromDateTime(activity.startTime).format(context)} - ${TimeOfDay.fromDateTime(activity.endTime).format(context)}',
              style: AppStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag(activity.category, AppColors.blue),
                const SizedBox(width: 8),
                _buildTag(
                    activity.priority, _getPriorityColor(activity.priority)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.overlay0),
              onPressed: () => _editActivity(activity),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.overlay0),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar actividad'),
                    content: Text(
                        '¿Estás seguro de que quieres eliminar "${activity.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: AppColors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _repository.deleteActivity(activity.id);
                  await _loadActivities();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppStyles.bodySmall.copyWith(color: color),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return AppColors.red;
      case 'media':
        return AppColors.yellow;
      case 'baja':
        return AppColors.green;
      default:
        return AppColors.overlay0;
    }
  }
}
