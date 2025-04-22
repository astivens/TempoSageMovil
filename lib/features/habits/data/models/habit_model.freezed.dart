// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HabitModel _$HabitModelFromJson(Map<String, dynamic> json) {
  return _HabitModel.fromJson(json);
}

/// @nodoc
mixin _$HabitModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(2)
  String get description => throw _privateConstructorUsedError;
  @HiveField(3)
  DateTime get startTime => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime get endTime => throw _privateConstructorUsedError;
  @HiveField(5)
  String get category => throw _privateConstructorUsedError;
  @HiveField(6)
  bool get isCompleted => throw _privateConstructorUsedError;
  @HiveField(7)
  int get streak => throw _privateConstructorUsedError;
  @HiveField(8)
  List<DateTime> get completedDates => throw _privateConstructorUsedError;
  @HiveField(9)
  List<int> get daysOfWeek => throw _privateConstructorUsedError;
  @HiveField(10)
  DateTime? get lastCompleted => throw _privateConstructorUsedError;
  @HiveField(11)
  int get totalCompletions => throw _privateConstructorUsedError;
  @HiveField(12)
  @TimeOfDayConverter()
  TimeOfDay get time => throw _privateConstructorUsedError;
  @HiveField(13)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this HabitModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitModelCopyWith<HabitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitModelCopyWith<$Res> {
  factory $HabitModelCopyWith(
          HabitModel value, $Res Function(HabitModel) then) =
      _$HabitModelCopyWithImpl<$Res, HabitModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String description,
      @HiveField(3) DateTime startTime,
      @HiveField(4) DateTime endTime,
      @HiveField(5) String category,
      @HiveField(6) bool isCompleted,
      @HiveField(7) int streak,
      @HiveField(8) List<DateTime> completedDates,
      @HiveField(9) List<int> daysOfWeek,
      @HiveField(10) DateTime? lastCompleted,
      @HiveField(11) int totalCompletions,
      @HiveField(12) @TimeOfDayConverter() TimeOfDay time,
      @HiveField(13) DateTime createdAt});
}

/// @nodoc
class _$HabitModelCopyWithImpl<$Res, $Val extends HabitModel>
    implements $HabitModelCopyWith<$Res> {
  _$HabitModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? category = null,
    Object? isCompleted = null,
    Object? streak = null,
    Object? completedDates = null,
    Object? daysOfWeek = null,
    Object? lastCompleted = freezed,
    Object? totalCompletions = null,
    Object? time = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      completedDates: null == completedDates
          ? _value.completedDates
          : completedDates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      daysOfWeek: null == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      lastCompleted: freezed == lastCompleted
          ? _value.lastCompleted
          : lastCompleted // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitModelImplCopyWith<$Res>
    implements $HabitModelCopyWith<$Res> {
  factory _$$HabitModelImplCopyWith(
          _$HabitModelImpl value, $Res Function(_$HabitModelImpl) then) =
      __$$HabitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String description,
      @HiveField(3) DateTime startTime,
      @HiveField(4) DateTime endTime,
      @HiveField(5) String category,
      @HiveField(6) bool isCompleted,
      @HiveField(7) int streak,
      @HiveField(8) List<DateTime> completedDates,
      @HiveField(9) List<int> daysOfWeek,
      @HiveField(10) DateTime? lastCompleted,
      @HiveField(11) int totalCompletions,
      @HiveField(12) @TimeOfDayConverter() TimeOfDay time,
      @HiveField(13) DateTime createdAt});
}

/// @nodoc
class __$$HabitModelImplCopyWithImpl<$Res>
    extends _$HabitModelCopyWithImpl<$Res, _$HabitModelImpl>
    implements _$$HabitModelImplCopyWith<$Res> {
  __$$HabitModelImplCopyWithImpl(
      _$HabitModelImpl _value, $Res Function(_$HabitModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? category = null,
    Object? isCompleted = null,
    Object? streak = null,
    Object? completedDates = null,
    Object? daysOfWeek = null,
    Object? lastCompleted = freezed,
    Object? totalCompletions = null,
    Object? time = null,
    Object? createdAt = null,
  }) {
    return _then(_$HabitModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      completedDates: null == completedDates
          ? _value._completedDates
          : completedDates // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      lastCompleted: freezed == lastCompleted
          ? _value.lastCompleted
          : lastCompleted // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveField(0)
class _$HabitModelImpl implements _HabitModel {
  const _$HabitModelImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.description,
      @HiveField(3) required this.startTime,
      @HiveField(4) required this.endTime,
      @HiveField(5) required this.category,
      @HiveField(6) required this.isCompleted,
      @HiveField(7) required this.streak,
      @HiveField(8) required final List<DateTime> completedDates,
      @HiveField(9) required final List<int> daysOfWeek,
      @HiveField(10) required this.lastCompleted,
      @HiveField(11) required this.totalCompletions,
      @HiveField(12) @TimeOfDayConverter() required this.time,
      @HiveField(13) required this.createdAt})
      : _completedDates = completedDates,
        _daysOfWeek = daysOfWeek;

  factory _$HabitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final DateTime startTime;
  @override
  @HiveField(4)
  final DateTime endTime;
  @override
  @HiveField(5)
  final String category;
  @override
  @HiveField(6)
  final bool isCompleted;
  @override
  @HiveField(7)
  final int streak;
  final List<DateTime> _completedDates;
  @override
  @HiveField(8)
  List<DateTime> get completedDates {
    if (_completedDates is EqualUnmodifiableListView) return _completedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedDates);
  }

  final List<int> _daysOfWeek;
  @override
  @HiveField(9)
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

  @override
  @HiveField(10)
  final DateTime? lastCompleted;
  @override
  @HiveField(11)
  final int totalCompletions;
  @override
  @HiveField(12)
  @TimeOfDayConverter()
  final TimeOfDay time;
  @override
  @HiveField(13)
  final DateTime createdAt;

  @override
  String toString() {
    return 'HabitModel(id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime, category: $category, isCompleted: $isCompleted, streak: $streak, completedDates: $completedDates, daysOfWeek: $daysOfWeek, lastCompleted: $lastCompleted, totalCompletions: $totalCompletions, time: $time, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            const DeepCollectionEquality()
                .equals(other._completedDates, _completedDates) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek) &&
            (identical(other.lastCompleted, lastCompleted) ||
                other.lastCompleted == lastCompleted) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      startTime,
      endTime,
      category,
      isCompleted,
      streak,
      const DeepCollectionEquality().hash(_completedDates),
      const DeepCollectionEquality().hash(_daysOfWeek),
      lastCompleted,
      totalCompletions,
      time,
      createdAt);

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitModelImplCopyWith<_$HabitModelImpl> get copyWith =>
      __$$HabitModelImplCopyWithImpl<_$HabitModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitModelImplToJson(
      this,
    );
  }
}

abstract class _HabitModel implements HabitModel {
  const factory _HabitModel(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String title,
      @HiveField(2) required final String description,
      @HiveField(3) required final DateTime startTime,
      @HiveField(4) required final DateTime endTime,
      @HiveField(5) required final String category,
      @HiveField(6) required final bool isCompleted,
      @HiveField(7) required final int streak,
      @HiveField(8) required final List<DateTime> completedDates,
      @HiveField(9) required final List<int> daysOfWeek,
      @HiveField(10) required final DateTime? lastCompleted,
      @HiveField(11) required final int totalCompletions,
      @HiveField(12) @TimeOfDayConverter() required final TimeOfDay time,
      @HiveField(13) required final DateTime createdAt}) = _$HabitModelImpl;

  factory _HabitModel.fromJson(Map<String, dynamic> json) =
      _$HabitModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get title;
  @override
  @HiveField(2)
  String get description;
  @override
  @HiveField(3)
  DateTime get startTime;
  @override
  @HiveField(4)
  DateTime get endTime;
  @override
  @HiveField(5)
  String get category;
  @override
  @HiveField(6)
  bool get isCompleted;
  @override
  @HiveField(7)
  int get streak;
  @override
  @HiveField(8)
  List<DateTime> get completedDates;
  @override
  @HiveField(9)
  List<int> get daysOfWeek;
  @override
  @HiveField(10)
  DateTime? get lastCompleted;
  @override
  @HiveField(11)
  int get totalCompletions;
  @override
  @HiveField(12)
  @TimeOfDayConverter()
  TimeOfDay get time;
  @override
  @HiveField(13)
  DateTime get createdAt;

  /// Create a copy of HabitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitModelImplCopyWith<_$HabitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
