import '../../../../core/utils/date_helper.dart';

/// Contract cancellation deadline risk classification
enum ContractRiskStatus {
  noContract('No Contract'),
  safe('Safe'),
  approaching('Notice Window Approaching'),
  critical('Action Required Soon'),
  cancellationWindowPassed('Cancellation Window Passed'),
  expired('Contract Period Concluded');

  final String label;
  const ContractRiskStatus(this.label);

  bool get isActionable =>
      this == ContractRiskStatus.approaching ||
      this == ContractRiskStatus.critical;
}

/// Represents an annual or multi-month contractual commitment with a required cancellation notice period
class ContractCommitment {
  final DateTime? startDate;
  final DateTime endDate; // Current binding commitment period end date
  final int
  cancellationNoticeDays; // Required advance notice (e.g. 14, 30, 60 days)
  final bool
  autoRenews; // Whether the contract auto-renews for another period if not cancelled
  final String? notes; // Provider-specific cancellation terms or penalties

  const ContractCommitment({
    this.startDate,
    required this.endDate,
    this.cancellationNoticeDays = 30,
    this.autoRenews = true,
    this.notes,
  });

  /// The exact calendar date by which cancellation must be initiated
  DateTime get cancellationDeadline => DateHelper.dateOnly(
    endDate,
  ).subtract(Duration(days: cancellationNoticeDays));

  /// Days remaining until the cancellation deadline
  int daysUntilDeadline(DateTime now) {
    final today = DateHelper.dateOnly(now);
    final deadline = DateHelper.dateOnly(cancellationDeadline);
    return deadline.difference(today).inDays;
  }

  /// Evaluates risk status mathematically against calendar dates
  ContractRiskStatus evaluateRisk(DateTime now) {
    final today = DateHelper.dateOnly(now);
    final end = DateHelper.dateOnly(endDate);
    final deadline = DateHelper.dateOnly(cancellationDeadline);

    if (today.isAfter(end)) {
      return ContractRiskStatus.expired;
    }

    if (!autoRenews) {
      return ContractRiskStatus.noContract;
    }

    final daysRemaining = deadline.difference(today).inDays;

    if (daysRemaining > 14) {
      return ContractRiskStatus.safe;
    } else if (daysRemaining >= 4 && daysRemaining <= 14) {
      return ContractRiskStatus.approaching;
    } else if (daysRemaining >= 0 && daysRemaining <= 3) {
      return ContractRiskStatus.critical;
    } else {
      return ContractRiskStatus.cancellationWindowPassed;
    }
  }

  ContractCommitment copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? cancellationNoticeDays,
    bool? autoRenews,
    String? notes,
  }) {
    return ContractCommitment(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancellationNoticeDays:
          cancellationNoticeDays ?? this.cancellationNoticeDays,
      autoRenews: autoRenews ?? this.autoRenews,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'cancellationNoticeDays': cancellationNoticeDays,
      'autoRenews': autoRenews,
      'notes': notes,
    };
  }

  factory ContractCommitment.fromJson(Map<String, dynamic> json) {
    return ContractCommitment(
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: DateTime.parse(json['endDate'] as String),
      cancellationNoticeDays:
          (json['cancellationNoticeDays'] as num?)?.toInt() ?? 30,
      autoRenews: json['autoRenews'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractCommitment &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          cancellationNoticeDays == other.cancellationNoticeDays &&
          autoRenews == other.autoRenews &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
    startDate,
    endDate,
    cancellationNoticeDays,
    autoRenews,
    notes,
  );
}
