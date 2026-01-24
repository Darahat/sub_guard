// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationEntity {
  String get id => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String? get payload => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  bool get isCancelled => throw _privateConstructorUsedError;
  String? get subscriptionId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationEntityCopyWith<NotificationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEntityCopyWith<$Res> {
  factory $NotificationEntityCopyWith(
          NotificationEntity value, $Res Function(NotificationEntity) then) =
      _$NotificationEntityCopyWithImpl<$Res, NotificationEntity>;
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      String title,
      String body,
      String? payload,
      DateTime scheduledAt,
      DateTime? deliveredAt,
      bool isCancelled,
      String? subscriptionId,
      DateTime? createdAt});
}

/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res, $Val extends NotificationEntity>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? payload = freezed,
    Object? scheduledAt = null,
    Object? deliveredAt = freezed,
    Object? isCancelled = null,
    Object? subscriptionId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionId: freezed == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationEntityImplCopyWith<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  factory _$$NotificationEntityImplCopyWith(_$NotificationEntityImpl value,
          $Res Function(_$NotificationEntityImpl) then) =
      __$$NotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      String title,
      String body,
      String? payload,
      DateTime scheduledAt,
      DateTime? deliveredAt,
      bool isCancelled,
      String? subscriptionId,
      DateTime? createdAt});
}

/// @nodoc
class __$$NotificationEntityImplCopyWithImpl<$Res>
    extends _$NotificationEntityCopyWithImpl<$Res, _$NotificationEntityImpl>
    implements _$$NotificationEntityImplCopyWith<$Res> {
  __$$NotificationEntityImplCopyWithImpl(_$NotificationEntityImpl _value,
      $Res Function(_$NotificationEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? payload = freezed,
    Object? scheduledAt = null,
    Object? deliveredAt = freezed,
    Object? isCancelled = null,
    Object? subscriptionId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$NotificationEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionId: freezed == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$NotificationEntityImpl implements _NotificationEntity {
  const _$NotificationEntityImpl(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      this.payload,
      required this.scheduledAt,
      this.deliveredAt,
      this.isCancelled = false,
      this.subscriptionId,
      this.createdAt});

  @override
  final String id;
  @override
  final NotificationType type;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? payload;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime? deliveredAt;
  @override
  @JsonKey()
  final bool isCancelled;
  @override
  final String? subscriptionId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, title: $title, body: $body, payload: $payload, scheduledAt: $scheduledAt, deliveredAt: $deliveredAt, isCancelled: $isCancelled, subscriptionId: $subscriptionId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, type, title, body, payload,
      scheduledAt, deliveredAt, isCancelled, subscriptionId, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      __$$NotificationEntityImplCopyWithImpl<_$NotificationEntityImpl>(
          this, _$identity);
}

abstract class _NotificationEntity implements NotificationEntity {
  const factory _NotificationEntity(
      {required final String id,
      required final NotificationType type,
      required final String title,
      required final String body,
      final String? payload,
      required final DateTime scheduledAt,
      final DateTime? deliveredAt,
      final bool isCancelled,
      final String? subscriptionId,
      final DateTime? createdAt}) = _$NotificationEntityImpl;

  @override
  String get id;
  @override
  NotificationType get type;
  @override
  String get title;
  @override
  String get body;
  @override
  String? get payload;
  @override
  DateTime get scheduledAt;
  @override
  DateTime? get deliveredAt;
  @override
  bool get isCancelled;
  @override
  String? get subscriptionId;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationSettingsEntity {
  bool get enabled => throw _privateConstructorUsedError;
  List<int> get defaultReminderDays => throw _privateConstructorUsedError;
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get vibrationEnabled => throw _privateConstructorUsedError;
  bool get badgeEnabled => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationSettingsEntityCopyWith<NotificationSettingsEntity>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsEntityCopyWith<$Res> {
  factory $NotificationSettingsEntityCopyWith(NotificationSettingsEntity value,
          $Res Function(NotificationSettingsEntity) then) =
      _$NotificationSettingsEntityCopyWithImpl<$Res,
          NotificationSettingsEntity>;
  @useResult
  $Res call(
      {bool enabled,
      List<int> defaultReminderDays,
      bool soundEnabled,
      bool vibrationEnabled,
      bool badgeEnabled,
      DateTime? updatedAt});
}

/// @nodoc
class _$NotificationSettingsEntityCopyWithImpl<$Res,
        $Val extends NotificationSettingsEntity>
    implements $NotificationSettingsEntityCopyWith<$Res> {
  _$NotificationSettingsEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? defaultReminderDays = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? badgeEnabled = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultReminderDays: null == defaultReminderDays
          ? _value.defaultReminderDays
          : defaultReminderDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrationEnabled: null == vibrationEnabled
          ? _value.vibrationEnabled
          : vibrationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      badgeEnabled: null == badgeEnabled
          ? _value.badgeEnabled
          : badgeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsEntityImplCopyWith<$Res>
    implements $NotificationSettingsEntityCopyWith<$Res> {
  factory _$$NotificationSettingsEntityImplCopyWith(
          _$NotificationSettingsEntityImpl value,
          $Res Function(_$NotificationSettingsEntityImpl) then) =
      __$$NotificationSettingsEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      List<int> defaultReminderDays,
      bool soundEnabled,
      bool vibrationEnabled,
      bool badgeEnabled,
      DateTime? updatedAt});
}

/// @nodoc
class __$$NotificationSettingsEntityImplCopyWithImpl<$Res>
    extends _$NotificationSettingsEntityCopyWithImpl<$Res,
        _$NotificationSettingsEntityImpl>
    implements _$$NotificationSettingsEntityImplCopyWith<$Res> {
  __$$NotificationSettingsEntityImplCopyWithImpl(
      _$NotificationSettingsEntityImpl _value,
      $Res Function(_$NotificationSettingsEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? defaultReminderDays = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? badgeEnabled = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$NotificationSettingsEntityImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultReminderDays: null == defaultReminderDays
          ? _value._defaultReminderDays
          : defaultReminderDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrationEnabled: null == vibrationEnabled
          ? _value.vibrationEnabled
          : vibrationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      badgeEnabled: null == badgeEnabled
          ? _value.badgeEnabled
          : badgeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$NotificationSettingsEntityImpl implements _NotificationSettingsEntity {
  const _$NotificationSettingsEntityImpl(
      {this.enabled = true,
      final List<int> defaultReminderDays = const [1, 7],
      this.soundEnabled = true,
      this.vibrationEnabled = true,
      this.badgeEnabled = true,
      this.updatedAt})
      : _defaultReminderDays = defaultReminderDays;

  @override
  @JsonKey()
  final bool enabled;
  final List<int> _defaultReminderDays;
  @override
  @JsonKey()
  List<int> get defaultReminderDays {
    if (_defaultReminderDays is EqualUnmodifiableListView)
      return _defaultReminderDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_defaultReminderDays);
  }

  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool vibrationEnabled;
  @override
  @JsonKey()
  final bool badgeEnabled;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationSettingsEntity(enabled: $enabled, defaultReminderDays: $defaultReminderDays, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, badgeEnabled: $badgeEnabled, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsEntityImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            const DeepCollectionEquality()
                .equals(other._defaultReminderDays, _defaultReminderDays) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.badgeEnabled, badgeEnabled) ||
                other.badgeEnabled == badgeEnabled) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      const DeepCollectionEquality().hash(_defaultReminderDays),
      soundEnabled,
      vibrationEnabled,
      badgeEnabled,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsEntityImplCopyWith<_$NotificationSettingsEntityImpl>
      get copyWith => __$$NotificationSettingsEntityImplCopyWithImpl<
          _$NotificationSettingsEntityImpl>(this, _$identity);
}

abstract class _NotificationSettingsEntity
    implements NotificationSettingsEntity {
  const factory _NotificationSettingsEntity(
      {final bool enabled,
      final List<int> defaultReminderDays,
      final bool soundEnabled,
      final bool vibrationEnabled,
      final bool badgeEnabled,
      final DateTime? updatedAt}) = _$NotificationSettingsEntityImpl;

  @override
  bool get enabled;
  @override
  List<int> get defaultReminderDays;
  @override
  bool get soundEnabled;
  @override
  bool get vibrationEnabled;
  @override
  bool get badgeEnabled;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsEntityImplCopyWith<_$NotificationSettingsEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
