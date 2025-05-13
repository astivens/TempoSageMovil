import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/activity_model.dart';
import '../widgets/activity_card.dart';
import '../widgets/add_activity_button.dart';
import '../widgets/daily_habits.dart';
import 'create_activity_screen.dart';
import '../../data/repositories/activity_repository.dart';
import '../../../../core/services/service_locator.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.activities,
        showBackButton: false,
        titleStyle: TextStyle(
          color: theme.colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onBackground),
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
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DailyHabits(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _activities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 60,
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.activityNoActivities,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.activityNoActivitiesToday,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateActivityScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    await _loadActivities();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: Text(l10n.createActivity),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _activities.length,
                          itemBuilder: (context, index) {
                            final activity = _activities[index];
                            return ActivityCard(
                              activity: activity,
                              onToggleComplete: () async {
                                final updatedActivity = activity.copyWith(
                                  isCompleted: !activity.isCompleted,
                                );
                                await _activityRepository
                                    .updateActivity(updatedActivity);
                                await _loadActivities();
                              },
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateActivityScreen(
                                      activity: activity,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  await _loadActivities();
                                }
                              },
                              onDelete: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(l10n.delete),
                                    content: Text(
                                      l10n.activityDeleteConfirmation,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(l10n.delete),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await _activityRepository
                                      .deleteActivity(activity.id);
                                  await _loadActivities();
                                }
                              },
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
