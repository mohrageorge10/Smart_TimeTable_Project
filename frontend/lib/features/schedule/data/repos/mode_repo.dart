import 'package:frontend/core/constants/app_data.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/features/schedule/data/models/schedule_model.dart';

class ModeRepository {
  static final Map<String, ScheduleModeConfig> modes = {
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
      academicYearLabel: AppStrings.academicYear,
      academicYears: AppData.academicYears,
      typeLabel: AppStrings.collegeType,
    ),
    'Hospital': ScheduleModeConfig(
      modeName: 'Hospital',
      nameLabel: 'Clinic Name',
      personLabel: 'Doctor',
      hasCapacity: false,
      hasAcademicYear: false,
      hasLocationType: false,
      hasLocationSettings: false,
      types: AppData.getTypes('Hospital'),
      specialties: AppData.getSpecialties('Hospital'),
      typeLabel: "Shift",
    ),
    'School': ScheduleModeConfig(
      modeName: 'School',
      nameLabel: 'Subject',
      personLabel: 'Teacher',
      hasCapacity: true,
      hasAcademicYear: true,
      hasLocationType: false,
      hasLocationSettings: true,
      types: AppData.getTypes('School'),
      specialties: AppData.getSpecialties('School'),
      academicYearLabel: AppStrings.academicYear,
      academicYears: AppData.academicYears,
    ),
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
    ),
  };
}
