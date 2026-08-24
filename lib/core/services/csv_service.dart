import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../features/subscriptions/domain/entities/subscription_entity.dart';
import '../utils/logger.dart';

/// Result object for CSV Import operations
class CsvImportResult {
  final List<SubscriptionEntity> subscriptions;
  final int totalRowsFound;
  final int validCount;
  final int skippedCount;
  final List<String> errorMessages;

  const CsvImportResult({
    required this.subscriptions,
    required this.totalRowsFound,
    required this.validCount,
    required this.skippedCount,
    this.errorMessages = const [],
  });

  bool get hasErrors => errorMessages.isNotEmpty;
  bool get isSuccessful => subscriptions.isNotEmpty;
}

/// Core service for exporting and importing subscription data in CSV format
class CsvService {
  final Uuid _uuid;

  CsvService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Standard CSV Header Row
  static const List<String> csvHeaders = [
    'ID',
    'Service Name',
    'Amount',
    'Currency',
    'Billing Cycle',
    'Next Billing Date',
    'Category',
    'Status',
    'Description',
    'Website URL',
    'Start Date',
    'Created At',
  ];

  /// Convert a list of SubscriptionEntity objects to an RFC 4180 CSV string
  String generateCsvString(List<SubscriptionEntity> subscriptions) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final rows = <List<dynamic>>[];

    // 1. Add Header row
    rows.add(csvHeaders);

    // 2. Add data rows
    for (final sub in subscriptions) {
      rows.add([
        sub.id,
        sub.serviceName,
        sub.amount.toStringAsFixed(2),
        sub.currency,
        sub.billingCycle.name,
        dateFormat.format(sub.nextBillingDate),
        sub.category ?? '',
        sub.status.name,
        sub.description ?? '',
        sub.websiteUrl ?? '',
        sub.startDate != null ? dateFormat.format(sub.startDate!) : '',
        sub.createdAt != null ? sub.createdAt!.toIso8601String() : '',
      ]);
    }

    const converter = ListToCsvConverter();
    return converter.convert(rows);
  }

  /// Exports subscriptions to a local file and triggers the native OS Share sheet
  Future<String?> exportAndShare(List<SubscriptionEntity> subscriptions) async {
    if (subscriptions.isEmpty) {
      logger.warning('CSV Export: No subscriptions to export.');
      return null;
    }

    try {
      final csvString = generateCsvString(subscriptions);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'SubGuard_Backup_$timestamp.csv';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csvString, encoding: utf8);

      logger.info('CSV file created at: $filePath');

      // Trigger native share sheet
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'text/csv', name: fileName)],
        subject: 'SubGuard Subscriptions Backup ($fileName)',
        text: 'Attached is your SubGuard subscriptions CSV backup file.',
      );

      return filePath;
    } catch (e, stackTrace) {
      logger.error('Error during CSV export & share: $e');
      logger.error(stackTrace.toString());
      rethrow;
    }
  }

  /// Opens the device file picker to select a .csv file and parses its contents
  Future<CsvImportResult?> pickAndParseCsv({required String userId}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        logger.info('User cancelled CSV file selection.');
        return null;
      }

      final pickedFile = result.files.first;
      String csvContent;

      if (pickedFile.bytes != null) {
        csvContent = utf8.decode(pickedFile.bytes!, allowMalformed: true);
      } else if (pickedFile.path != null) {
        final file = File(pickedFile.path!);
        csvContent = await file.readAsString();
      } else {
        throw Exception('Could not read file data.');
      }

      return parseCsvString(csvContent, userId: userId);
    } catch (e, stackTrace) {
      logger.error('Failed to pick/parse CSV: $e');
      logger.error(stackTrace.toString());
      rethrow;
    }
  }

  /// Parses raw CSV string content into validated SubscriptionEntity objects
  CsvImportResult parseCsvString(String csvContent, {required String userId}) {
    if (csvContent.trim().isEmpty) {
      return const CsvImportResult(
        subscriptions: [],
        totalRowsFound: 0,
        validCount: 0,
        skippedCount: 0,
        errorMessages: ['Selected CSV file is empty.'],
      );
    }

    const converter = CsvToListConverter(eol: '\n', shouldParseNumbers: false);
    final rawRows = converter.convert(csvContent);

    if (rawRows.isEmpty) {
      return const CsvImportResult(
        subscriptions: [],
        totalRowsFound: 0,
        validCount: 0,
        skippedCount: 0,
        errorMessages: ['No readable rows found in CSV file.'],
      );
    }

    // Identify header indices dynamically
    final headerRow = rawRows.first.map((e) => e.toString().trim().toLowerCase()).toList();

    int nameIndex = _findHeaderIndex(headerRow, ['service name', 'name', 'service', 'title', 'subscription']);
    int amountIndex = _findHeaderIndex(headerRow, ['amount', 'cost', 'price', 'fee']);
    int currencyIndex = _findHeaderIndex(headerRow, ['currency', 'curr']);
    int cycleIndex = _findHeaderIndex(headerRow, ['billing cycle', 'cycle', 'frequency', 'period']);
    int nextDateIndex = _findHeaderIndex(headerRow, ['next billing date', 'next billing', 'next payment', 'renewal date', 'date']);
    int categoryIndex = _findHeaderIndex(headerRow, ['category', 'group', 'type']);
    int statusIndex = _findHeaderIndex(headerRow, ['status', 'state']);
    int descIndex = _findHeaderIndex(headerRow, ['description', 'notes', 'note']);
    int webIndex = _findHeaderIndex(headerRow, ['website url', 'website', 'url', 'link']);
    int startDateIndex = _findHeaderIndex(headerRow, ['start date', 'started', 'created']);

    // Fallbacks if headers weren't named standardly
    if (nameIndex == -1) nameIndex = 1;
    if (amountIndex == -1) amountIndex = 2;
    if (currencyIndex == -1) currencyIndex = 3;
    if (cycleIndex == -1) cycleIndex = 4;
    if (nextDateIndex == -1) nextDateIndex = 5;

    final validList = <SubscriptionEntity>[];
    final errors = <String>[];
    int skippedCount = 0;

    // Process each row (skip header)
    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue; // Skip empty trailing lines
      }

      try {
        final serviceName = _getValue(row, nameIndex);
        if (serviceName.isEmpty) {
          skippedCount++;
          errors.add('Row ${i + 1}: Skipped due to missing Service Name.');
          continue;
        }

        // Parse Amount safely (stripping '$', '€', '£', ',')
        final rawAmount = _getValue(row, amountIndex);
        final cleanAmountStr = rawAmount.replaceAll(RegExp(r'[^\d.]'), '');
        final amount = double.tryParse(cleanAmountStr) ?? 0.0;

        if (amount <= 0) {
          skippedCount++;
          errors.add('Row ${i + 1} ($serviceName): Invalid or zero amount "$rawAmount".');
          continue;
        }

        // Parse Currency (default USD)
        String currency = _getValue(row, currencyIndex).toUpperCase();
        if (currency.isEmpty || currency.length > 4) {
          currency = 'USD';
        }

        // Parse BillingCycle
        final rawCycle = _getValue(row, cycleIndex).toLowerCase();
        final cycle = _parseBillingCycle(rawCycle);

        // Parse Next Billing Date
        final rawNextDate = _getValue(row, nextDateIndex);
        final nextBillingDate = _parseDate(rawNextDate) ?? DateTime.now().add(const Duration(days: 30));

        // Parse Status
        final rawStatus = _getValue(row, statusIndex).toLowerCase();
        final status = _parseStatus(rawStatus);

        // Optional fields
        final category = categoryIndex != -1 ? _getValue(row, categoryIndex) : null;
        final description = descIndex != -1 ? _getValue(row, descIndex) : null;
        final websiteUrl = webIndex != -1 ? _getValue(row, webIndex) : null;
        final startDate = startDateIndex != -1 ? _parseDate(_getValue(row, startDateIndex)) : null;

        final subscription = SubscriptionEntity(
          id: _uuid.v4(),
          userId: userId,
          serviceName: serviceName,
          amount: amount,
          currency: currency,
          billingCycle: cycle,
          nextBillingDate: nextBillingDate,
          category: category?.isNotEmpty == true ? category : 'Entertainment',
          status: status,
          description: description?.isNotEmpty == true ? description : null,
          websiteUrl: websiteUrl?.isNotEmpty == true ? websiteUrl : null,
          startDate: startDate,
          notificationDays: const ['1', '3'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        validList.add(subscription);
      } catch (e) {
        skippedCount++;
        errors.add('Row ${i + 1}: Parsing error ($e).');
      }
    }

    return CsvImportResult(
      subscriptions: validList,
      totalRowsFound: rawRows.length - 1,
      validCount: validList.length,
      skippedCount: skippedCount,
      errorMessages: errors,
    );
  }

  int _findHeaderIndex(List<String> headers, List<String> candidateNames) {
    for (final candidate in candidateNames) {
      final index = headers.indexOf(candidate);
      if (index != -1) return index;
    }
    return -1;
  }

  String _getValue(List<dynamic> row, int index) {
    if (index >= 0 && index < row.length) {
      return row[index].toString().trim();
    }
    return '';
  }

  BillingCycle _parseBillingCycle(String input) {
    switch (input) {
      case 'daily':
        return BillingCycle.daily;
      case 'weekly':
        return BillingCycle.weekly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
      case 'annual':
      case 'annually':
        return BillingCycle.yearly;
      case 'monthly':
      default:
        return BillingCycle.monthly;
    }
  }

  SubscriptionStatus _parseStatus(String input) {
    switch (input) {
      case 'cancelled':
      case 'canceled':
        return SubscriptionStatus.cancelled;
      case 'paused':
        return SubscriptionStatus.paused;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'active':
      default:
        return SubscriptionStatus.active;
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;

    // 1. Try ISO 8601 (yyyy-MM-dd or yyyy-MM-ddTHH:mm:ss)
    final isoDate = DateTime.tryParse(dateStr.trim());
    if (isoDate != null) return isoDate;

    // 2. Try common formats
    final formats = [
      DateFormat('yyyy-MM-dd'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('MM-dd-yyyy'),
      DateFormat('yyyy/MM/dd'),
    ];

    for (final format in formats) {
      try {
        return format.parseStrict(dateStr.trim());
      } catch (_) {}
    }

    return null;
  }
}
