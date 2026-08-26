import '../models/preset_service.dart';
import 'categories.dart';
import 'cloud_presets.dart';
import 'education_news_presets.dart';
import 'fitness_presets.dart';
import 'gaming_presets.dart';
import 'music_presets.dart';
import 'productivity_presets.dart';
import 'security_presets.dart';
import 'software_dev_presets.dart';
import 'streaming_presets.dart';

class PresetCatalog {
  static List<String> get categories => PresetCategories.list;

  static final List<PresetService> services = [
    ...streamingPresets,
    ...musicPresets,
    ...productivityPresets,
    ...cloudPresets,
    ...softwareDevPresets,
    ...securityPresets,
    ...gamingPresets,
    ...fitnessPresets,
    ...educationNewsPresets,
  ];

  /// Find preset by exact ID
  static PresetService? getById(String id) {
    return services.where((s) => s.id == id).firstOrNull;
  }

  /// Find preset by name or registered alias (case-insensitive)
  static PresetService? getByName(String name) {
    final clean = name.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 1. Direct name match
    final direct = services
        .where((s) => s.name.toLowerCase() == clean)
        .firstOrNull;
    if (direct != null) return direct;

    // 2. Alias match
    for (final service in services) {
      if (service.aliases.any((a) => a.toLowerCase() == clean)) {
        return service;
      }
    }

    // 3. Contains match (e.g. "Netflix 4K" -> "Netflix")
    for (final service in services) {
      if (clean.contains(service.name.toLowerCase()) ||
          service.aliases.any((a) => clean.contains(a.toLowerCase()))) {
        return service;
      }
    }

    return null;
  }

  /// Filter presets by category
  static List<PresetService> getByCategory(String category) {
    if (category == PresetCategories.all) return services;
    return services.where((s) => s.category == category).toList();
  }

  /// Search presets by query string
  static List<PresetService> search(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return services;

    return services.where((s) {
      final nameMatches = s.name.toLowerCase().contains(clean);
      final categoryMatches = s.category.toLowerCase().contains(clean);
      final aliasMatches = s.aliases.any(
        (a) => a.toLowerCase().contains(clean),
      );
      return nameMatches || categoryMatches || aliasMatches;
    }).toList();
  }
}
