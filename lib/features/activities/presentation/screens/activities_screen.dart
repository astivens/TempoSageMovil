import 'package:flutter/material.dart';
import 'package:temposage/core/constants/app_colors.dart';
import 'package:temposage/core/constants/app_styles.dart';
import 'package:temposage/features/activities/data/models/activity_model.dart';
import 'package:temposage/features/activities/data/repositories/activity_repository.dart';
import 'package:temposage/features/activities/domain/entities/activity.dart';
import 'package:temposage/features/activities/presentation/screens/create_activity_screen.dart';
import 'package:temposage/features/activities/presentation/widgets/activity_card.dart';
import 'package:temposage/features/activities/presentation/widgets/add_activity_button.dart';
import 'package:temposage/features/activities/presentation/widgets/daily_habits.dart';
import 'package:temposage/core/services/service_locator.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final ActivityRepository _activityRepository =
      ServiceLocator.instance.activityRepository;
  List<ActivityModel> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _activityRepository.getAllActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActivityCompletion(Activity activity) async {
    final activityModel = _activities.firstWhere((a) => a.id == activity.id);
    activityModel.isCompleted = !activityModel.isCompleted;
    await _activityRepository.updateActivity(activityModel);
    await _loadActivities();
  }

  Future<void> _deleteActivity(Activity activity) async {
    await _activityRepository.deleteActivity(activity.id);
    await _loadActivities();
  }

  Future<void> _editActivity(Activity activity) async {
    final activityModel = _activities.firstWhere((a) => a.id == activity.id);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateActivityScreen(
          activity: activityModel,
        ),
      ),
    );
    if (result == true) {
      await _loadActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Actividades',
                style: AppStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const DailyHabits(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _activities.isEmpty
                      ? Center(
                          child: Text(
                            'No hay actividades',
                            style: AppStyles.bodyLarge.copyWith(
                              color: AppColors.overlay0,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _activities.length,
                          itemBuilder: (context, index) {
                            final activity = Activity(
                              id: _activities[index].id,
                              name: _activities[index].title,
                              date: _activities[index].startTime,
                              category: _activities[index].category,
                              description: _activities[index].description,
                              isCompleted: _activities[index].isCompleted,
                            );
                            return ActivityCard(
                              activity: _activities[index],
                              onToggleComplete: () =>
                                  _toggleActivityCompletion(activity),
                              onEdit: () => _editActivity(activity),
                              onDelete: () => _deleteActivity(activity),
                              onTap: () {},
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddActivityButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateActivityScreen(),
            ),
          );
          if (result == true) {
            await _loadActivities();
          }
        },
      ),
    );
  }
}
