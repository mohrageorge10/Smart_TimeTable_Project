class ScheduleModeConfig {
  final String modeName;
  final String nameLabel;
  final String personLabel;
  final bool hasCapacity;
  final bool hasLocationSettings;
  final bool hasLocationType;

  final List<String> types;
  final List<String> specialties;
  final bool hasAcademicYear;
  final String? academicYearLabel;
  final List<String>? locations;
  final List<String>? academicYears;
  final String? typeLabel;
  final String? SpecialtyLabel;

  final bool hasDynamicSection;
  final String? sectionLabel;
  final List<String> Function(String level)? getSectionsForLevel;

  final bool hasAvailableDays;
  final List<String> excludedDays;

  ScheduleModeConfig({
    required this.modeName,
    required this.nameLabel,
    required this.personLabel,
    required this.hasCapacity,
    required this.hasLocationSettings,
    required this.hasLocationType,
    required this.types,
    required this.specialties,
    required this.hasAcademicYear,
    this.academicYearLabel,
    this.locations,
    this.academicYears,
    this.typeLabel,
    this.SpecialtyLabel,
    this.hasDynamicSection = false,
    this.sectionLabel,
    this.getSectionsForLevel,
    this.hasAvailableDays = false,
    this.excludedDays = const [],
  });
}
