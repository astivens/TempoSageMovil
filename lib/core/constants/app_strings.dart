class AppStrings {
  // App name
  static const String appName = 'TempoSage';

  // Bottom navigation bar
  static const String home = 'Home';
  static const String calendar = 'Calendar';
  static const String activities = 'Activities';
  static const String statistics = 'Statistics';
  static const String settings = 'Settings';

  // Time blocks
  static const String timeBlocks = 'Time Blocks';
  static const String addTimeBlock = 'Add Time Block';
  static const String editTimeBlock = 'Edit Time Block';
  static const String deleteTimeBlock = 'Delete Time Block';
  static const String timeBlockTitle = 'Title';
  static const String timeBlockDescription = 'Description';
  static const String startTime = 'Start Time';
  static const String endTime = 'End Time';
  static const String category = 'Category';
  static const String focusTime = 'Focus Time';
  static const String color = 'Color';

  // Categories
  static const String work = 'Work';
  static const String study = 'Study';
  static const String exercise = 'Exercise';
  static const String leisure = 'Leisure';
  static const String other = 'Other';

  // Activities
  static const String addActivity = 'Add Activity';
  static const String editActivity = 'Edit Activity';
  static const String deleteActivity = 'Delete Activity';
  static const String activityName = 'Name';
  static const String activityDescription = 'Description';
  static const String activityDate = 'Date';

  // Common actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';

  // Error messages
  static const String errorRequired = 'This field is required';
  static const String errorInvalidTime = 'Invalid time format';
  static const String errorEndTimeBeforeStart =
      'End time must be after start time';
  static const String errorGeneric = 'Something went wrong';

  // Success messages
  static const String successSaved = 'Successfully saved';
  static const String successDeleted = 'Successfully deleted';
  static const String successUpdated = 'Successfully updated';

  // Confirmation messages
  static const String confirmDelete =
      'Are you sure you want to delete this item?';
  static const String confirmDiscard =
      'Are you sure you want to discard changes?';

  // Empty states
  static const String emptyTimeBlocks = 'No time blocks yet';
  static const String emptyActivities = 'No activities yet';
  static const String emptyStatistics = 'No statistics available';
}
