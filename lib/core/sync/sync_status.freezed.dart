// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SyncStatus {
  bool get isSyncing => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;
  int get pendingChanges => throw _privateConstructorUsedError;
  SyncState get state => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SyncStatusCopyWith<SyncStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStatusCopyWith<$Res> {
  factory $SyncStatusCopyWith(
          SyncStatus value, $Res Function(SyncStatus) then) =
      _$SyncStatusCopyWithImpl<$Res, SyncStatus>;
  @useResult
  $Res call(
      {bool isSyncing,
      bool hasError,
      String? errorMessage,
      DateTime? lastSyncedAt,
      int pendingChanges,
      SyncState state});
}

/// @nodoc
class _$SyncStatusCopyWithImpl<$Res, $Val extends SyncStatus>
    implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? lastSyncedAt = freezed,
    Object? pendingChanges = null,
    Object? state = null,
  }) {
    return _then(_value.copyWith(
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pendingChanges: null == pendingChanges
          ? _value.pendingChanges
          : pendingChanges // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as SyncState,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncStatusImplCopyWith<$Res>
    implements $SyncStatusCopyWith<$Res> {
  factory _$$SyncStatusImplCopyWith(
          _$SyncStatusImpl value, $Res Function(_$SyncStatusImpl) then) =
      __$$SyncStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSyncing,
      bool hasError,
      String? errorMessage,
      DateTime? lastSyncedAt,
      int pendingChanges,
      SyncState state});
}

/// @nodoc
class __$$SyncStatusImplCopyWithImpl<$Res>
    extends _$SyncStatusCopyWithImpl<$Res, _$SyncStatusImpl>
    implements _$$SyncStatusImplCopyWith<$Res> {
  __$$SyncStatusImplCopyWithImpl(
      _$SyncStatusImpl _value, $Res Function(_$SyncStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? lastSyncedAt = freezed,
    Object? pendingChanges = null,
    Object? state = null,
  }) {
    return _then(_$SyncStatusImpl(
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pendingChanges: null == pendingChanges
          ? _value.pendingChanges
          : pendingChanges // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as SyncState,
    ));
  }
}

/// @nodoc

class _$SyncStatusImpl implements _SyncStatus {
  const _$SyncStatusImpl(
      {this.isSyncing = false,
      this.hasError = false,
      this.errorMessage,
      this.lastSyncedAt,
      this.pendingChanges = 0,
      this.state = SyncState.idle});

  @override
  @JsonKey()
  final bool isSyncing;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;
  @override
  final DateTime? lastSyncedAt;
  @override
  @JsonKey()
  final int pendingChanges;
  @override
  @JsonKey()
  final SyncState state;

  @override
  String toString() {
    return 'SyncStatus(isSyncing: $isSyncing, hasError: $hasError, errorMessage: $errorMessage, lastSyncedAt: $lastSyncedAt, pendingChanges: $pendingChanges, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStatusImpl &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            (identical(other.pendingChanges, pendingChanges) ||
                other.pendingChanges == pendingChanges) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSyncing, hasError,
      errorMessage, lastSyncedAt, pendingChanges, state);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStatusImplCopyWith<_$SyncStatusImpl> get copyWith =>
      __$$SyncStatusImplCopyWithImpl<_$SyncStatusImpl>(this, _$identity);
}

abstract class _SyncStatus implements SyncStatus {
  const factory _SyncStatus(
      {final bool isSyncing,
      final bool hasError,
      final String? errorMessage,
      final DateTime? lastSyncedAt,
      final int pendingChanges,
      final SyncState state}) = _$SyncStatusImpl;

  @override
  bool get isSyncing;
  @override
  bool get hasError;
  @override
  String? get errorMessage;
  @override
  DateTime? get lastSyncedAt;
  @override
  int get pendingChanges;
  @override
  SyncState get state;
  @override
  @JsonKey(ignore: true)
  _$$SyncStatusImplCopyWith<_$SyncStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
