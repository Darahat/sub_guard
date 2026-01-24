// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SpendingDataPoint {
  DateTime get date => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  int get subscriptionCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SpendingDataPointCopyWith<SpendingDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpendingDataPointCopyWith<$Res> {
  factory $SpendingDataPointCopyWith(
          SpendingDataPoint value, $Res Function(SpendingDataPoint) then) =
      _$SpendingDataPointCopyWithImpl<$Res, SpendingDataPoint>;
  @useResult
  $Res call({DateTime date, double amount, int subscriptionCount});
}

/// @nodoc
class _$SpendingDataPointCopyWithImpl<$Res, $Val extends SpendingDataPoint>
    implements $SpendingDataPointCopyWith<$Res> {
  _$SpendingDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? amount = null,
    Object? subscriptionCount = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      subscriptionCount: null == subscriptionCount
          ? _value.subscriptionCount
          : subscriptionCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpendingDataPointImplCopyWith<$Res>
    implements $SpendingDataPointCopyWith<$Res> {
  factory _$$SpendingDataPointImplCopyWith(_$SpendingDataPointImpl value,
          $Res Function(_$SpendingDataPointImpl) then) =
      __$$SpendingDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double amount, int subscriptionCount});
}

/// @nodoc
class __$$SpendingDataPointImplCopyWithImpl<$Res>
    extends _$SpendingDataPointCopyWithImpl<$Res, _$SpendingDataPointImpl>
    implements _$$SpendingDataPointImplCopyWith<$Res> {
  __$$SpendingDataPointImplCopyWithImpl(_$SpendingDataPointImpl _value,
      $Res Function(_$SpendingDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? amount = null,
    Object? subscriptionCount = null,
  }) {
    return _then(_$SpendingDataPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      subscriptionCount: null == subscriptionCount
          ? _value.subscriptionCount
          : subscriptionCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SpendingDataPointImpl implements _SpendingDataPoint {
  const _$SpendingDataPointImpl(
      {required this.date,
      required this.amount,
      required this.subscriptionCount});

  @override
  final DateTime date;
  @override
  final double amount;
  @override
  final int subscriptionCount;

  @override
  String toString() {
    return 'SpendingDataPoint(date: $date, amount: $amount, subscriptionCount: $subscriptionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpendingDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.subscriptionCount, subscriptionCount) ||
                other.subscriptionCount == subscriptionCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, amount, subscriptionCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpendingDataPointImplCopyWith<_$SpendingDataPointImpl> get copyWith =>
      __$$SpendingDataPointImplCopyWithImpl<_$SpendingDataPointImpl>(
          this, _$identity);
}

abstract class _SpendingDataPoint implements SpendingDataPoint {
  const factory _SpendingDataPoint(
      {required final DateTime date,
      required final double amount,
      required final int subscriptionCount}) = _$SpendingDataPointImpl;

  @override
  DateTime get date;
  @override
  double get amount;
  @override
  int get subscriptionCount;
  @override
  @JsonKey(ignore: true)
  _$$SpendingDataPointImplCopyWith<_$SpendingDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CategorySpending {
  String get category => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  int get subscriptionCount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategorySpendingCopyWith<CategorySpending> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorySpendingCopyWith<$Res> {
  factory $CategorySpendingCopyWith(
          CategorySpending value, $Res Function(CategorySpending) then) =
      _$CategorySpendingCopyWithImpl<$Res, CategorySpending>;
  @useResult
  $Res call(
      {String category,
      double amount,
      int subscriptionCount,
      double percentage});
}

/// @nodoc
class _$CategorySpendingCopyWithImpl<$Res, $Val extends CategorySpending>
    implements $CategorySpendingCopyWith<$Res> {
  _$CategorySpendingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? amount = null,
    Object? subscriptionCount = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      subscriptionCount: null == subscriptionCount
          ? _value.subscriptionCount
          : subscriptionCount // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategorySpendingImplCopyWith<$Res>
    implements $CategorySpendingCopyWith<$Res> {
  factory _$$CategorySpendingImplCopyWith(_$CategorySpendingImpl value,
          $Res Function(_$CategorySpendingImpl) then) =
      __$$CategorySpendingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category,
      double amount,
      int subscriptionCount,
      double percentage});
}

/// @nodoc
class __$$CategorySpendingImplCopyWithImpl<$Res>
    extends _$CategorySpendingCopyWithImpl<$Res, _$CategorySpendingImpl>
    implements _$$CategorySpendingImplCopyWith<$Res> {
  __$$CategorySpendingImplCopyWithImpl(_$CategorySpendingImpl _value,
      $Res Function(_$CategorySpendingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? amount = null,
    Object? subscriptionCount = null,
    Object? percentage = null,
  }) {
    return _then(_$CategorySpendingImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      subscriptionCount: null == subscriptionCount
          ? _value.subscriptionCount
          : subscriptionCount // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CategorySpendingImpl implements _CategorySpending {
  const _$CategorySpendingImpl(
      {required this.category,
      required this.amount,
      required this.subscriptionCount,
      required this.percentage});

  @override
  final String category;
  @override
  final double amount;
  @override
  final int subscriptionCount;
  @override
  final double percentage;

  @override
  String toString() {
    return 'CategorySpending(category: $category, amount: $amount, subscriptionCount: $subscriptionCount, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorySpendingImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.subscriptionCount, subscriptionCount) ||
                other.subscriptionCount == subscriptionCount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, category, amount, subscriptionCount, percentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorySpendingImplCopyWith<_$CategorySpendingImpl> get copyWith =>
      __$$CategorySpendingImplCopyWithImpl<_$CategorySpendingImpl>(
          this, _$identity);
}

abstract class _CategorySpending implements CategorySpending {
  const factory _CategorySpending(
      {required final String category,
      required final double amount,
      required final int subscriptionCount,
      required final double percentage}) = _$CategorySpendingImpl;

  @override
  String get category;
  @override
  double get amount;
  @override
  int get subscriptionCount;
  @override
  double get percentage;
  @override
  @JsonKey(ignore: true)
  _$$CategorySpendingImplCopyWith<_$CategorySpendingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SubscriptionStats {
  int get totalSubscriptions => throw _privateConstructorUsedError;
  int get activeSubscriptions => throw _privateConstructorUsedError;
  int get pausedSubscriptions => throw _privateConstructorUsedError;
  int get cancelledSubscriptions => throw _privateConstructorUsedError;
  double get totalMonthlySpending => throw _privateConstructorUsedError;
  double get totalYearlySpending => throw _privateConstructorUsedError;
  double get averageSubscriptionCost => throw _privateConstructorUsedError;
  double get highestSubscription => throw _privateConstructorUsedError;
  double get lowestSubscription => throw _privateConstructorUsedError;
  int get subscriptionsThisMonth => throw _privateConstructorUsedError;
  int get subscriptionsThisYear => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubscriptionStatsCopyWith<SubscriptionStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStatsCopyWith<$Res> {
  factory $SubscriptionStatsCopyWith(
          SubscriptionStats value, $Res Function(SubscriptionStats) then) =
      _$SubscriptionStatsCopyWithImpl<$Res, SubscriptionStats>;
  @useResult
  $Res call(
      {int totalSubscriptions,
      int activeSubscriptions,
      int pausedSubscriptions,
      int cancelledSubscriptions,
      double totalMonthlySpending,
      double totalYearlySpending,
      double averageSubscriptionCost,
      double highestSubscription,
      double lowestSubscription,
      int subscriptionsThisMonth,
      int subscriptionsThisYear});
}

/// @nodoc
class _$SubscriptionStatsCopyWithImpl<$Res, $Val extends SubscriptionStats>
    implements $SubscriptionStatsCopyWith<$Res> {
  _$SubscriptionStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSubscriptions = null,
    Object? activeSubscriptions = null,
    Object? pausedSubscriptions = null,
    Object? cancelledSubscriptions = null,
    Object? totalMonthlySpending = null,
    Object? totalYearlySpending = null,
    Object? averageSubscriptionCost = null,
    Object? highestSubscription = null,
    Object? lowestSubscription = null,
    Object? subscriptionsThisMonth = null,
    Object? subscriptionsThisYear = null,
  }) {
    return _then(_value.copyWith(
      totalSubscriptions: null == totalSubscriptions
          ? _value.totalSubscriptions
          : totalSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      activeSubscriptions: null == activeSubscriptions
          ? _value.activeSubscriptions
          : activeSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      pausedSubscriptions: null == pausedSubscriptions
          ? _value.pausedSubscriptions
          : pausedSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledSubscriptions: null == cancelledSubscriptions
          ? _value.cancelledSubscriptions
          : cancelledSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      totalMonthlySpending: null == totalMonthlySpending
          ? _value.totalMonthlySpending
          : totalMonthlySpending // ignore: cast_nullable_to_non_nullable
              as double,
      totalYearlySpending: null == totalYearlySpending
          ? _value.totalYearlySpending
          : totalYearlySpending // ignore: cast_nullable_to_non_nullable
              as double,
      averageSubscriptionCost: null == averageSubscriptionCost
          ? _value.averageSubscriptionCost
          : averageSubscriptionCost // ignore: cast_nullable_to_non_nullable
              as double,
      highestSubscription: null == highestSubscription
          ? _value.highestSubscription
          : highestSubscription // ignore: cast_nullable_to_non_nullable
              as double,
      lowestSubscription: null == lowestSubscription
          ? _value.lowestSubscription
          : lowestSubscription // ignore: cast_nullable_to_non_nullable
              as double,
      subscriptionsThisMonth: null == subscriptionsThisMonth
          ? _value.subscriptionsThisMonth
          : subscriptionsThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      subscriptionsThisYear: null == subscriptionsThisYear
          ? _value.subscriptionsThisYear
          : subscriptionsThisYear // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionStatsImplCopyWith<$Res>
    implements $SubscriptionStatsCopyWith<$Res> {
  factory _$$SubscriptionStatsImplCopyWith(_$SubscriptionStatsImpl value,
          $Res Function(_$SubscriptionStatsImpl) then) =
      __$$SubscriptionStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalSubscriptions,
      int activeSubscriptions,
      int pausedSubscriptions,
      int cancelledSubscriptions,
      double totalMonthlySpending,
      double totalYearlySpending,
      double averageSubscriptionCost,
      double highestSubscription,
      double lowestSubscription,
      int subscriptionsThisMonth,
      int subscriptionsThisYear});
}

/// @nodoc
class __$$SubscriptionStatsImplCopyWithImpl<$Res>
    extends _$SubscriptionStatsCopyWithImpl<$Res, _$SubscriptionStatsImpl>
    implements _$$SubscriptionStatsImplCopyWith<$Res> {
  __$$SubscriptionStatsImplCopyWithImpl(_$SubscriptionStatsImpl _value,
      $Res Function(_$SubscriptionStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSubscriptions = null,
    Object? activeSubscriptions = null,
    Object? pausedSubscriptions = null,
    Object? cancelledSubscriptions = null,
    Object? totalMonthlySpending = null,
    Object? totalYearlySpending = null,
    Object? averageSubscriptionCost = null,
    Object? highestSubscription = null,
    Object? lowestSubscription = null,
    Object? subscriptionsThisMonth = null,
    Object? subscriptionsThisYear = null,
  }) {
    return _then(_$SubscriptionStatsImpl(
      totalSubscriptions: null == totalSubscriptions
          ? _value.totalSubscriptions
          : totalSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      activeSubscriptions: null == activeSubscriptions
          ? _value.activeSubscriptions
          : activeSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      pausedSubscriptions: null == pausedSubscriptions
          ? _value.pausedSubscriptions
          : pausedSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledSubscriptions: null == cancelledSubscriptions
          ? _value.cancelledSubscriptions
          : cancelledSubscriptions // ignore: cast_nullable_to_non_nullable
              as int,
      totalMonthlySpending: null == totalMonthlySpending
          ? _value.totalMonthlySpending
          : totalMonthlySpending // ignore: cast_nullable_to_non_nullable
              as double,
      totalYearlySpending: null == totalYearlySpending
          ? _value.totalYearlySpending
          : totalYearlySpending // ignore: cast_nullable_to_non_nullable
              as double,
      averageSubscriptionCost: null == averageSubscriptionCost
          ? _value.averageSubscriptionCost
          : averageSubscriptionCost // ignore: cast_nullable_to_non_nullable
              as double,
      highestSubscription: null == highestSubscription
          ? _value.highestSubscription
          : highestSubscription // ignore: cast_nullable_to_non_nullable
              as double,
      lowestSubscription: null == lowestSubscription
          ? _value.lowestSubscription
          : lowestSubscription // ignore: cast_nullable_to_non_nullable
              as double,
      subscriptionsThisMonth: null == subscriptionsThisMonth
          ? _value.subscriptionsThisMonth
          : subscriptionsThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      subscriptionsThisYear: null == subscriptionsThisYear
          ? _value.subscriptionsThisYear
          : subscriptionsThisYear // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SubscriptionStatsImpl extends _SubscriptionStats {
  const _$SubscriptionStatsImpl(
      {required this.totalSubscriptions,
      required this.activeSubscriptions,
      required this.pausedSubscriptions,
      required this.cancelledSubscriptions,
      required this.totalMonthlySpending,
      required this.totalYearlySpending,
      required this.averageSubscriptionCost,
      required this.highestSubscription,
      required this.lowestSubscription,
      required this.subscriptionsThisMonth,
      required this.subscriptionsThisYear})
      : super._();

  @override
  final int totalSubscriptions;
  @override
  final int activeSubscriptions;
  @override
  final int pausedSubscriptions;
  @override
  final int cancelledSubscriptions;
  @override
  final double totalMonthlySpending;
  @override
  final double totalYearlySpending;
  @override
  final double averageSubscriptionCost;
  @override
  final double highestSubscription;
  @override
  final double lowestSubscription;
  @override
  final int subscriptionsThisMonth;
  @override
  final int subscriptionsThisYear;

  @override
  String toString() {
    return 'SubscriptionStats(totalSubscriptions: $totalSubscriptions, activeSubscriptions: $activeSubscriptions, pausedSubscriptions: $pausedSubscriptions, cancelledSubscriptions: $cancelledSubscriptions, totalMonthlySpending: $totalMonthlySpending, totalYearlySpending: $totalYearlySpending, averageSubscriptionCost: $averageSubscriptionCost, highestSubscription: $highestSubscription, lowestSubscription: $lowestSubscription, subscriptionsThisMonth: $subscriptionsThisMonth, subscriptionsThisYear: $subscriptionsThisYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStatsImpl &&
            (identical(other.totalSubscriptions, totalSubscriptions) ||
                other.totalSubscriptions == totalSubscriptions) &&
            (identical(other.activeSubscriptions, activeSubscriptions) ||
                other.activeSubscriptions == activeSubscriptions) &&
            (identical(other.pausedSubscriptions, pausedSubscriptions) ||
                other.pausedSubscriptions == pausedSubscriptions) &&
            (identical(other.cancelledSubscriptions, cancelledSubscriptions) ||
                other.cancelledSubscriptions == cancelledSubscriptions) &&
            (identical(other.totalMonthlySpending, totalMonthlySpending) ||
                other.totalMonthlySpending == totalMonthlySpending) &&
            (identical(other.totalYearlySpending, totalYearlySpending) ||
                other.totalYearlySpending == totalYearlySpending) &&
            (identical(
                    other.averageSubscriptionCost, averageSubscriptionCost) ||
                other.averageSubscriptionCost == averageSubscriptionCost) &&
            (identical(other.highestSubscription, highestSubscription) ||
                other.highestSubscription == highestSubscription) &&
            (identical(other.lowestSubscription, lowestSubscription) ||
                other.lowestSubscription == lowestSubscription) &&
            (identical(other.subscriptionsThisMonth, subscriptionsThisMonth) ||
                other.subscriptionsThisMonth == subscriptionsThisMonth) &&
            (identical(other.subscriptionsThisYear, subscriptionsThisYear) ||
                other.subscriptionsThisYear == subscriptionsThisYear));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSubscriptions,
      activeSubscriptions,
      pausedSubscriptions,
      cancelledSubscriptions,
      totalMonthlySpending,
      totalYearlySpending,
      averageSubscriptionCost,
      highestSubscription,
      lowestSubscription,
      subscriptionsThisMonth,
      subscriptionsThisYear);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStatsImplCopyWith<_$SubscriptionStatsImpl> get copyWith =>
      __$$SubscriptionStatsImplCopyWithImpl<_$SubscriptionStatsImpl>(
          this, _$identity);
}

abstract class _SubscriptionStats extends SubscriptionStats {
  const factory _SubscriptionStats(
      {required final int totalSubscriptions,
      required final int activeSubscriptions,
      required final int pausedSubscriptions,
      required final int cancelledSubscriptions,
      required final double totalMonthlySpending,
      required final double totalYearlySpending,
      required final double averageSubscriptionCost,
      required final double highestSubscription,
      required final double lowestSubscription,
      required final int subscriptionsThisMonth,
      required final int subscriptionsThisYear}) = _$SubscriptionStatsImpl;
  const _SubscriptionStats._() : super._();

  @override
  int get totalSubscriptions;
  @override
  int get activeSubscriptions;
  @override
  int get pausedSubscriptions;
  @override
  int get cancelledSubscriptions;
  @override
  double get totalMonthlySpending;
  @override
  double get totalYearlySpending;
  @override
  double get averageSubscriptionCost;
  @override
  double get highestSubscription;
  @override
  double get lowestSubscription;
  @override
  int get subscriptionsThisMonth;
  @override
  int get subscriptionsThisYear;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionStatsImplCopyWith<_$SubscriptionStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TopSubscription {
  String get serviceName => throw _privateConstructorUsedError;
  double get monthlyAmount => throw _privateConstructorUsedError;
  double get yearlyAmount => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TopSubscriptionCopyWith<TopSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopSubscriptionCopyWith<$Res> {
  factory $TopSubscriptionCopyWith(
          TopSubscription value, $Res Function(TopSubscription) then) =
      _$TopSubscriptionCopyWithImpl<$Res, TopSubscription>;
  @useResult
  $Res call(
      {String serviceName,
      double monthlyAmount,
      double yearlyAmount,
      String category,
      String? logoUrl});
}

/// @nodoc
class _$TopSubscriptionCopyWithImpl<$Res, $Val extends TopSubscription>
    implements $TopSubscriptionCopyWith<$Res> {
  _$TopSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceName = null,
    Object? monthlyAmount = null,
    Object? yearlyAmount = null,
    Object? category = null,
    Object? logoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      serviceName: null == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyAmount: null == monthlyAmount
          ? _value.monthlyAmount
          : monthlyAmount // ignore: cast_nullable_to_non_nullable
              as double,
      yearlyAmount: null == yearlyAmount
          ? _value.yearlyAmount
          : yearlyAmount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopSubscriptionImplCopyWith<$Res>
    implements $TopSubscriptionCopyWith<$Res> {
  factory _$$TopSubscriptionImplCopyWith(_$TopSubscriptionImpl value,
          $Res Function(_$TopSubscriptionImpl) then) =
      __$$TopSubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serviceName,
      double monthlyAmount,
      double yearlyAmount,
      String category,
      String? logoUrl});
}

/// @nodoc
class __$$TopSubscriptionImplCopyWithImpl<$Res>
    extends _$TopSubscriptionCopyWithImpl<$Res, _$TopSubscriptionImpl>
    implements _$$TopSubscriptionImplCopyWith<$Res> {
  __$$TopSubscriptionImplCopyWithImpl(
      _$TopSubscriptionImpl _value, $Res Function(_$TopSubscriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceName = null,
    Object? monthlyAmount = null,
    Object? yearlyAmount = null,
    Object? category = null,
    Object? logoUrl = freezed,
  }) {
    return _then(_$TopSubscriptionImpl(
      serviceName: null == serviceName
          ? _value.serviceName
          : serviceName // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyAmount: null == monthlyAmount
          ? _value.monthlyAmount
          : monthlyAmount // ignore: cast_nullable_to_non_nullable
              as double,
      yearlyAmount: null == yearlyAmount
          ? _value.yearlyAmount
          : yearlyAmount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TopSubscriptionImpl implements _TopSubscription {
  const _$TopSubscriptionImpl(
      {required this.serviceName,
      required this.monthlyAmount,
      required this.yearlyAmount,
      required this.category,
      this.logoUrl});

  @override
  final String serviceName;
  @override
  final double monthlyAmount;
  @override
  final double yearlyAmount;
  @override
  final String category;
  @override
  final String? logoUrl;

  @override
  String toString() {
    return 'TopSubscription(serviceName: $serviceName, monthlyAmount: $monthlyAmount, yearlyAmount: $yearlyAmount, category: $category, logoUrl: $logoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopSubscriptionImpl &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.monthlyAmount, monthlyAmount) ||
                other.monthlyAmount == monthlyAmount) &&
            (identical(other.yearlyAmount, yearlyAmount) ||
                other.yearlyAmount == yearlyAmount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, serviceName, monthlyAmount, yearlyAmount, category, logoUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TopSubscriptionImplCopyWith<_$TopSubscriptionImpl> get copyWith =>
      __$$TopSubscriptionImplCopyWithImpl<_$TopSubscriptionImpl>(
          this, _$identity);
}

abstract class _TopSubscription implements TopSubscription {
  const factory _TopSubscription(
      {required final String serviceName,
      required final double monthlyAmount,
      required final double yearlyAmount,
      required final String category,
      final String? logoUrl}) = _$TopSubscriptionImpl;

  @override
  String get serviceName;
  @override
  double get monthlyAmount;
  @override
  double get yearlyAmount;
  @override
  String get category;
  @override
  String? get logoUrl;
  @override
  @JsonKey(ignore: true)
  _$$TopSubscriptionImplCopyWith<_$TopSubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
