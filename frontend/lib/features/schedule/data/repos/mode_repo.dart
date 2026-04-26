import 'package:frontend/core/constants/app_data.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/features/schedule/data/models/schedule_model.dart';

class ModeRepository {
  static final Map<String, ScheduleModeConfig> modes = {

    // ── College (University + School sub-levels) ────────────
    'College': ScheduleModeConfig(
      modeName: 'College',
      nameLabel: 'Course Name',
      personLabel: 'Lecturer Name',
      hasCapacity: true,
      hasAcademicYear: true,
      hasLocationType: true,
      hasLocationSettings: true,
      types: AppData.getTypes('College'),
      locations: AppData.collegeLocations,
      specialties: AppData.getSpecialties('College'),
      academicYearLabel: 'Level',
      academicYears: AppData.universityLevels,
      typeLabel: AppStrings.collegeType,
      hasDynamicSection: true,
      sectionLabel: 'Section',
      getSectionsForLevel: AppData.getCollegeSections,
      hasAvailableDays: true,
      excludedDays: AppData.collegExcludedDays,
    ),

    // ── Hospital ─────────────────────────────────────────────
    'Hospital': ScheduleModeConfig(
      modeName: 'Hospital',
      nameLabel: 'Clinic / Shift Name',
      personLabel: 'Doctor',
      hasCapacity: false,
      hasAcademicYear: false,
      hasLocationType: false,
      hasLocationSettings: false,
      types: AppData.getTypes('Hospital'),
      specialties: AppData.getSpecialties('Hospital'),
      typeLabel: "Shift",
      hasDynamicSection: false,
      hasAvailableDays: true,
      excludedDays: AppData.hospitalExcludedDays,
    ),

    // ── School ───────────────────────────────────────────────
    'School': ScheduleModeConfig(
      modeName: 'School',
      nameLabel: 'Subject',
      personLabel: 'Teacher',
      hasCapacity: true,
      hasAcademicYear: true,
      hasLocationType: false,
      hasLocationSettings: true,
      types: AppData.getTypes('School'),
      specialties: [],
      academicYearLabel: 'Level',
      academicYears: AppData.schoolLevels,
      hasDynamicSection: true,
      sectionLabel: 'Class',
      getSectionsForLevel: AppData.getSchoolClasses,
      hasAvailableDays: true,
      excludedDays: AppData.schoolExcludedDays,
    ),

    // ── Event ────────────────────────────────────────────────
    'Event': ScheduleModeConfig(
      modeName: 'Event',
      nameLabel: 'Session Name',
      personLabel: 'Speaker',
      hasCapacity: true,
      hasAcademicYear: true,
      hasLocationType: true,
      hasLocationSettings: true,
      types: AppData.getTypes('Event'),
      locations: AppData.eventLocations,
      specialties: AppData.getSpecialties('Event'),
      academicYearLabel: AppStrings.targetAudience,
      academicYears: AppData.audiences,
      hasAvailableDays: false,
      excludedDays: AppData.eventExcludedDays,
    ),
  };
}
