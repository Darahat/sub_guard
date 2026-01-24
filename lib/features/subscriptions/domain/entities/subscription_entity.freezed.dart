// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscriptionEntity {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get serviceName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  BillingCycle get billingCycle => throw _privateConstructorUsedError;
  DateTime get nextBillingDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get websiteUrl => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  List<String> get notificationDays => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get cancellationDate => throw _privateConstructorUsedError;
  DateTime? get cancelledDate =>
      throw _privateConstructorUsedError; // Added for cancelled subscriptions
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubscriptionEntityCopyWith<SubscriptionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionEntityCopyWith<$Res> {
  factory $SubscriptionEntityCopyWith(
          SubscriptionEntity value, $Res Function(SubscriptionEntity) then) =
      _$SubscriptionEntityCopyWithImpl<$Res, SubscriptionEntity>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String serviceName,
      double amount,
      String currency,
      BillingCycle billingCycle,
      DateTime nextBillingDate,
      String? description,
      String? category,
      String? logoUrl,
      String? websiteUrl,
      SubscriptionStatus status,
      List<String> notificationDays,
      DateTime? startDate,
      DateTime? cancellationDate,
      DateTime? cancelledDate,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$SubscriptionEntityCopyWithImpl<$Res, $Val extends SubscriptionEntity>
    implements $SubscriptionEntityCopyWith<$Res> {
  _$SubscriptionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? serviceName = null,
    Object? amount = null,
    Object? currency = null,
    Object? billingCycle = null,
    Object? nextBillingDate = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? logoUrl = freezed,
    Object? websiteUrl = freezed,
    Object? status = null,
    Object? notificationDays = null,
    Object? startDate = freezed,
    Object? cancellationDate = freezed,
    Object? cancelledDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceName: null == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      billingCycle: null == billingCycle
          ? _value.billingCycle
          : billingCycle // ignore: cast_nullable_to_non_nullable
              as BillingCycle,
      nextBillingDate: null == nextBillingDate
          ? _value.nextBillingDate
          : nextBillingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      notificationDays: null == notificationDays
          ? _value.notificationDays
          : notificationDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationDate: freezed == cancellationDate
          ? _value.cancellationDate
          : cancellationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledDate: freezed == cancelledDate
          ? _value.cancelledDate
          : cancelledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionEntityImplCopyWith<$Res>
    implements $SubscriptionEntityCopyWith<$Res> {
  factory _$$SubscriptionEntityImplCopyWith(_$SubscriptionEntityImpl value,
          $Res Function(_$SubscriptionEntityImpl) then) =
      __$$SubscriptionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String serviceName,
      double amount,
      String currency,
      BillingCycle billingCycle,
      DateTime nextBillingDate,
      String? description,
      String? category,
      String? logoUrl,
      String? websiteUrl,
      SubscriptionStatus status,
      List<String> notificationDays,
      DateTime? startDate,
      DateTime? cancellationDate,
      DateTime? cancelledDate,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$SubscriptionEntityImplCopyWithImpl<$Res>
    extends _$SubscriptionEntityCopyWithImpl<$Res, _$SubscriptionEntityImpl>
    implements _$$SubscriptionEntityImplCopyWith<$Res> {
  __$$SubscriptionEntityImplCopyWithImpl(_$SubscriptionEntityImpl _value,
      $Res Function(_$SubscriptionEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? serviceName = null,
    Object? amount = null,
    Object? currency = null,
    Object? billingCycle = null,
    Object? nextBillingDate = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? logoUrl = freezed,
    Object? websiteUrl = freezed,
    Object? status = null,
    Object? notificationDays = null,
    Object? startDate = freezed,
    Object? cancellationDate = freezed,
    Object? cancelledDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SubscriptionEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceName: null == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      billingCycle: null == billingCycle
          ? _value.billingCycle
          : billingCycle // ignore: cast_nullable_to_non_nullable
              as BillingCycle,
      nextBillingDate: null == nextBillingDate
          ? _value.nextBillingDate
          : nextBillingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      notificationDays: null == notificationDays
          ? _value._notificationDays
          : notificationDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationDate: freezed == cancellationDate
          ? _value.cancellationDate
          : cancellationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledDate: freezed == cancelledDate
          ? _value.cancelledDate
          : cancelledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$SubscriptionEntityImpl extends _SubscriptionEntity {
  const _$SubscriptionEntityImpl(
      {required this.id,
      required this.userId,
      required this.serviceName,
      required this.amount,
      required this.currency,
      required this.billingCycle,
      required this.nextBillingDate,
      this.description,
      this.category,
      this.logoUrl,
      this.websiteUrl,
      this.status = SubscriptionStatus.active,
      final List<String> notificationDays = const [],
      this.startDate,
      this.cancellationDate,
      this.cancelledDate,
      this.createdAt,
      this.updatedAt})
      : _notificationDays = notificationDays,
        super._();

  @override
  final String id;
  @override
  final String userId;
  @override
  final String serviceName;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final BillingCycle billingCycle;
  @override
  final DateTime nextBillingDate;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? logoUrl;
  @override
  final String? websiteUrl;
  @override
  @JsonKey()
  final SubscriptionStatus status;
  final List<String> _notificationDays;
  @override
  @JsonKey()
  List<String> get notificationDays {
    if (_notificationDays is EqualUnmodifiableListView)
      return _notificationDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notificationDays);
  }

  @override
  final DateTime? startDate;
  @override
  final DateTime? cancellationDate;
  @override
  final DateTime? cancelledDate;
// Added for cancelled subscriptions
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SubscriptionEntity(id: $id, userId: $userId, serviceName: $serviceName, amount: $amount, currency: $currency, billingCycle: $billingCycle, nextBillingDate: $nextBillingDate, description: $description, category: $category, logoUrl: $logoUrl, websiteUrl: $websiteUrl, status: $status, notificationDays: $notificationDays, startDate: $startDate, cancellationDate: $cancellationDate, cancelledDate: $cancelledDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.billingCycle, billingCycle) ||
                other.billingCycle == billingCycle) &&
            (identical(other.nextBillingDate, nextBillingDate) ||
                other.nextBillingDate == nextBillingDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._notificationDays, _notificationDays) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.cancellationDate, cancellationDate) ||
                other.cancellationDate == cancellationDate) &&
            (identical(other.cancelledDate, cancelledDate) ||
                other.cancelledDate == cancelledDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      serviceName,
      amount,
      currency,
      billingCycle,
      nextBillingDate,
      description,
      category,
      logoUrl,
      websiteUrl,
      status,
      const DeepCollectionEquality().hash(_notificationDays),
      startDate,
      cancellationDate,
      cancelledDate,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionEntityImplCopyWith<_$SubscriptionEntityImpl> get copyWith =>
      __$$SubscriptionEntityImplCopyWithImpl<_$SubscriptionEntityImpl>(
          this, _$identity);
}

abstract class _SubscriptionEntity extends SubscriptionEntity {
  const factory _SubscriptionEntity(
      {required final String id,
      required final String userId,
      required final String serviceName,
      required final double amount,
      required final String currency,
      required final BillingCycle billingCycle,
      required final DateTime nextBillingDate,
      final String? description,
      final String? category,
      final String? logoUrl,
      final String? websiteUrl,
      final SubscriptionStatus status,
      final List<String> notificationDays,
      final DateTime? startDate,
      final DateTime? cancellationDate,
      final DateTime? cancelledDate,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$SubscriptionEntityImpl;
  const _SubscriptionEntity._() : super._();

  @override
  String get id;
  @override
  String get userId;
  @override
  String get serviceName;
  @override
  double get amount;
  @override
  String get currency;
  @override
  BillingCycle get billingCycle;
  @override
  DateTime get nextBillingDate;
  @override
  String? get description;
  @override
  String? get category;
  @override
  String? get logoUrl;
  @override
  String? get websiteUrl;
  @override
  SubscriptionStatus get status;
  @override
  List<String> get notificationDays;
  @override
  DateTime? get startDate;
  @override
  DateTime? get cancellationDate;
  @override
  DateTime? get cancelledDate;
  @override // Added for cancelled subscriptions
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionEntityImplCopyWith<_$SubscriptionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
