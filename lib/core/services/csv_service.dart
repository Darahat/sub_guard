import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../features/subscriptions/domain/entities/subscription_entity.dart';
import '../utils/logger.dart';

enum ExportFormat {
  excel('Microsoft Excel (.xlsx)', 'xlsx'),
  csv('CSV Document (.csv)', 'csv');

  final String label;
  final String extension;
  const ExportFormat(this.label, this.extension);
}

/// Result object for Import operations
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

/// Universal Service for exporting and importing subscription data in Excel (.xlsx) and CSV (.csv) formats
class CsvService {
  final Uuid _uuid;

  CsvService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Standard Table Header Row
  static const List<String> tableHeaders = [
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
  ];

  /// Convert a list of SubscriptionEntity objects to an RFC 4180 CSV string with UTF-8 BOM
  String generateCsvString(List<SubscriptionEntity> subscriptions) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final rows = <List<dynamic>>[];

    // 1. Add Header row
    rows.add(tableHeaders);

    // 2. Add data rows
    for (final sub in subscriptions) {
      rows.add([
        sub.serviceName,
        sub.amount.toStringAsFixed(2),
        sub.currency,
        sub.billingCycle.name,
        dateFormat.format(sub.nextBillingDate),
        sub.category ?? 'Other',
        sub.status.name,
        sub.description ?? '',
        sub.websiteUrl ?? '',
        sub.startDate != null ? dateFormat.format(sub.startDate!) : '',
      ]);
    }

    // Prepend UTF-8 BOM (\uFEFF) so Excel on Windows/Mac opens CSV without character corruption
    return '\uFEFF${csv.encode(rows)}';
  }

  /// Exports subscriptions as native Microsoft Excel (.xlsx) workbook and shares via OS sheet
  Future<String?> exportToExcel(List<SubscriptionEntity> subscriptions) async {
    if (subscriptions.isEmpty) {
      logger.warning('Excel Export: No subscriptions to export.');
      return null;
    }

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Subscriptions'];
      excel.setDefaultSheet('Subscriptions');
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Header row
      sheet.appendRow(tableHeaders.map((h) => TextCellValue(h)).toList());

      final dateFormat = DateFormat('yyyy-MM-dd');

      // Data rows
      for (final sub in subscriptions) {
        sheet.appendRow([
          TextCellValue(sub.serviceName),
          DoubleCellValue(sub.amount),
          TextCellValue(sub.currency),
          TextCellValue(sub.billingCycle.name),
          TextCellValue(dateFormat.format(sub.nextBillingDate)),
          TextCellValue(sub.category ?? 'Other'),
          TextCellValue(sub.status.name),
          TextCellValue(sub.description ?? ''),
          TextCellValue(sub.websiteUrl ?? ''),
          TextCellValue(
            sub.startDate != null ? dateFormat.format(sub.startDate!) : '',
          ),
        ]);
      }

      final bytes = excel.save();
      if (bytes == null) {
        throw Exception('Failed to generate Excel bytes.');
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'SubGuard_Subscriptions_$timestamp.xlsx';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      logger.info('Excel file created at: $filePath');

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              filePath,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              name: fileName,
            ),
          ],
          subject: 'SubGuard Subscriptions Backup ($fileName)',
          text: 'Attached is your SubGuard Excel backup spreadsheet.',
        ),
      );

      return filePath;
    } catch (e, stackTrace) {
      logger.error('Error during Excel export & share: $e');
      logger.error(stackTrace.toString());
      rethrow;
    }
  }

  /// Exports subscriptions as CSV file and shares via OS sheet
  Future<String?> exportToCsv(List<SubscriptionEntity> subscriptions) async {
    if (subscriptions.isEmpty) {
      logger.warning('CSV Export: No subscriptions to export.');
      return null;
    }

    try {
      final csvString = generateCsvString(subscriptions);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'SubGuard_Subscriptions_$timestamp.csv';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csvString, encoding: utf8);

      logger.info('CSV file created at: $filePath');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'text/csv', name: fileName)],
          subject: 'SubGuard Subscriptions Backup ($fileName)',
          text: 'Attached is your SubGuard CSV backup file.',
        ),
      );

      return filePath;
    } catch (e, stackTrace) {
      logger.error('Error during CSV export & share: $e');
      logger.error(stackTrace.toString());
      rethrow;
    }
  }

  /// Universal Export: Exports based on selected format
  Future<String?> exportAndShare(
    List<SubscriptionEntity> subscriptions, {
    ExportFormat format = ExportFormat.excel,
  }) async {
    if (format == ExportFormat.excel) {
      return exportToExcel(subscriptions);
    } else {
      return exportToCsv(subscriptions);
    }
  }

  /// Universal Import: Opens file picker for .xlsx, .xls, and .csv files
  Future<CsvImportResult?> pickAndParse({required String userId}) async {
    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (pickedFile == null) {
        logger.info('User cancelled file selection.');
        return null;
      }

      final extension = pickedFile.name.split('.').last.toLowerCase();
      final bytes = await pickedFile.readAsBytes();

      if (extension == 'xlsx' || extension == 'xls') {
        final excel = Excel.decodeBytes(bytes);
        final rows = <List<dynamic>>[];

        for (final table in excel.tables.keys) {
          final sheet = excel.tables[table];
          if (sheet == null) continue;

          for (final row in sheet.rows) {
            rows.add(
              row.map((cell) {
                if (cell == null || cell.value == null) return '';
                final val = cell.value;
                if (val is TextCellValue) return val.value.text ?? '';
                if (val is IntCellValue) return val.value.toString();
                if (val is DoubleCellValue) return val.value.toString();
                if (val is DateCellValue) {
                  return '${val.year}-${val.month.toString().padLeft(2, '0')}-${val.day.toString().padLeft(2, '0')}';
                }
                if (val is DateTimeCellValue) {
                  return '${val.year}-${val.month.toString().padLeft(2, '0')}-${val.day.toString().padLeft(2, '0')}';
                }
                return val.toString();
              }).toList(),
            );
          }
          if (rows.isNotEmpty) break;
        }

        return parseRows(rows, userId: userId);
      } else {
        // CSV decoding
        final csvString = utf8.decode(bytes, allowMalformed: true);
        return parseCsvString(csvString, userId: userId);
      }
    } catch (e, stackTrace) {
      logger.error('Failed to pick/parse import file: $e');
      logger.error(stackTrace.toString());
      rethrow;
    }
  }

  /// Alias for backward compatibility
  Future<CsvImportResult?> pickAndParseCsv({required String userId}) =>
      pickAndParse(userId: userId);

  /// Parses raw CSV string content into validated SubscriptionEntity objects
  CsvImportResult parseCsvString(String csvContent, {required String userId}) {
    if (csvContent.trim().isEmpty) {
      return const CsvImportResult(
        subscriptions: [],
        totalRowsFound: 0,
        validCount: 0,
        skippedCount: 0,
        errorMessages: ['Selected file is empty.'],
      );
    }

    // Clean BOM if present
    var cleanContent = csvContent;
    if (cleanContent.startsWith('\uFEFF')) {
      cleanContent = cleanContent.substring(1);
    }

    final rawRows = csv.decode(cleanContent);
    return parseRows(rawRows, userId: userId);
  }

  /// Parses standardized table rows into validated SubscriptionEntity objects
  CsvImportResult parseRows(
    List<List<dynamic>> rawRows, {
    required String userId,
  }) {
    if (rawRows.isEmpty) {
      return const CsvImportResult(
        subscriptions: [],
        totalRowsFound: 0,
        validCount: 0,
        skippedCount: 0,
        errorMessages: ['No readable rows found in file.'],
      );
    }

    // Identify header indices dynamically
    final headerRow = rawRows.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

    int nameIndex = _findHeaderIndex(headerRow, [
      'service name',
      'name',
      'service',
      'title',
      'subscription',
    ]);
    int amountIndex = _findHeaderIndex(headerRow, [
      'amount',
      'cost',
      'price',
      'fee',
    ]);
    int currencyIndex = _findHeaderIndex(headerRow, ['currency', 'curr']);
    int cycleIndex = _findHeaderIndex(headerRow, [
      'billing cycle',
      'cycle',
      'frequency',
      'period',
    ]);
    int nextDateIndex = _findHeaderIndex(headerRow, [
      'next billing date',
      'next billing',
      'next payment',
      'renewal date',
      'date',
    ]);
    int categoryIndex = _findHeaderIndex(headerRow, [
      'category',
      'group',
      'type',
    ]);
    int statusIndex = _findHeaderIndex(headerRow, ['status', 'state']);
    int descIndex = _findHeaderIndex(headerRow, [
      'description',
      'notes',
      'note',
    ]);
    int webIndex = _findHeaderIndex(headerRow, [
      'website url',
      'website',
      'url',
      'link',
    ]);
    int startDateIndex = _findHeaderIndex(headerRow, [
      'start date',
      'started',
      'created',
    ]);

    // Fallbacks if headers weren't named standardly
    if (nameIndex == -1) nameIndex = 0;
    if (amountIndex == -1) amountIndex = 1;
    if (currencyIndex == -1) currencyIndex = 2;
    if (cycleIndex == -1) cycleIndex = 3;
    if (nextDateIndex == -1) nextDateIndex = 4;

    final validList = <SubscriptionEntity>[];
    final errors = <String>[];
    int skippedCount = 0;

    // Process each row (skip header)
    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.isEmpty ||
          (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue; // Skip empty trailing lines
      }

      try {
        final serviceName = _getValue(row, nameIndex);
        if (serviceName.isEmpty) {
          skippedCount++;
          errors.add('Row ${i + 1}: Skipped due to missing Service Name.');
          continue;
        }

        // Parse Amount safely (stripping currency symbols)
        final rawAmount = _getValue(row, amountIndex);
        final cleanAmountStr = rawAmount.replaceAll(RegExp(r'[^\d.]'), '');
        final amount = double.tryParse(cleanAmountStr) ?? 0.0;

        if (amount <= 0) {
          skippedCount++;
          errors.add(
            'Row ${i + 1} ($serviceName): Invalid or zero amount "$rawAmount".',
          );
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
        final nextBillingDate =
            _parseDate(rawNextDate) ??
            DateTime.now().add(const Duration(days: 30));

        // Parse Status
        final rawStatus = _getValue(row, statusIndex).toLowerCase();
        final status = _parseStatus(rawStatus);

        // Optional fields
        final category = categoryIndex != -1
            ? _getValue(row, categoryIndex)
            : null;
        final description = descIndex != -1 ? _getValue(row, descIndex) : null;
        final websiteUrl = webIndex != -1 ? _getValue(row, webIndex) : null;
        final startDate = startDateIndex != -1
            ? _parseDate(_getValue(row, startDateIndex))
            : null;

        final subscription = SubscriptionEntity(
          id: _uuid.v4(),
          userId: userId,
          serviceName: serviceName,
          amount: amount,
          currency: currency,
          billingCycle: cycle,
          nextBillingDate: nextBillingDate,
          category: category?.isNotEmpty == true ? category : 'Other',
          status: status,
          description: description?.isNotEmpty == true ? description : null,
          websiteUrl: websiteUrl?.isNotEmpty == true ? websiteUrl : null,
          startDate: startDate,
          notificationDays: const ['7', '3', '1'],
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

    final isoDate = DateTime.tryParse(dateStr.trim());
    if (isoDate != null) return isoDate;

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
