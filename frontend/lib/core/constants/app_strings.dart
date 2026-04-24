class AppStrings {
  // Common
  static const String appTitle = "Smart TimeTable";
  static const String generateSchedule = "Generate Schedule";
  static const String errorEmptyFields = "Please fill all required fields";
  static const String timeSettings = "Time Settings";
  static const String locationSettings = "Location Settings";
  static const String basicInfo = "Basic Information";
// College
  static const String collegeAdd = "Add New Course";
  static const String collegeName = "Course Name";
  static const String collegePerson = "Lecturer Name";
  static const String collegeCapacity = "Number of Students";
  static const String collegeType = "Course Type";
  static const String collegeSpecialty = "Major";
  static const String academicYear = "Academic Year";
  static const String collegeLabel = "Course";
  // Hospital
  static const String hospitalAdd = "Add New Shift / Clinic";
  static const String hospitalName = "Clinic Name";
  static const String hospitalPerson = "Doctor Name";
  static const String hospitalCapacity = "Number of Patients";
  static const String hospitalType = "Shift Type";
  static const String hospitalSpecialty = "Department";
  static const String hospitalLabel = "Clinic/Shift";
  // School
  static const String schoolAdd = "Add New Subject";
  static const String schoolName = "Subject Name";
  static const String schoolPerson = "Teacher Name";
  static const String schoolCapacity = "Number of Students";
  static const String schoolType = "Class Type";
  static const String schoolSpecialty = "Grade Level";
  static const String schoolLabel = "Subject";
  // Event
  static const String eventAdd = "Add New Session";
  static const String eventName = "Session Name";
  static const String eventPerson = "Speaker Name";
  static const String eventCapacity = "Number of Attendees";
  static const String eventType = "Session Type";
  static const String targetAudience = "Target Audience";
  static const String eventSpecialty = "Track / Category";
  static const String eventLabel = "Session";

  // Dynamic getters based on mode
  static String getLabel(String mode) {
    switch (mode) {
      case 'Hospital':
        return hospitalLabel;
      case 'School':
        return schoolLabel;
      case 'Event':
        return eventLabel;
      default:
        return collegeLabel
        ; // College
    }
  }

  static String getNameLabel(String mode) {
    switch (mode) {
      case 'Hospital':
        return hospitalName;
      case 'School':
        return schoolName;
      case 'Event':
        return eventName;
      default:
        return collegeName;
    }
  }

  static String getPersonLabel(String mode) {
    switch (mode) {
      case 'Hospital':
        return hospitalPerson;
      case 'School':
        return schoolPerson;
      case 'Event':
        return eventPerson;
      default:
        return collegePerson;
    }
  }

  static String getCapacityLabel(String mode) {
    switch (mode) {
      case 'Hospital':
        return hospitalCapacity;
      case 'School':
        return schoolCapacity;
      case 'Event':
        return eventCapacity;
      default:
        return collegeCapacity;
    }
  }

  static String getTypeLabel(String mode) {
    switch (mode) {
      case 'Hospital':
        return hospitalType;
      case 'School':
        return schoolType;
      case 'Event':
        return eventType;
      default:
        return collegeType;
    }
  }

  static String getSpecialtyLabel(String mode) {
    switch (mode) {
      case 'Hospital':
        return hospitalSpecialty;
      case 'School':
        return schoolSpecialty;
      case 'Event':
        return eventSpecialty;
      default:
        return collegeSpecialty;
    }
  }

  static String getLocationNameLabel(String mode) {
    switch (mode) {
      case 'Hospital': return "Clinic/Ward Name (e.g., ER, Room 302)";
      case 'School': return "Classroom Name (e.g., Class 1A, Lab)";
      case 'Event': return "Zone Name (e.g., Main Stage)";
      default: return "Room/Hall Name (e.g., Hall 1, Room A2)";
    }
  }

  static String getLocationTypeLabel(String mode) {
    switch (mode) {
      case 'Hospital': return "Location Type (Clinic, Ward, OR)";
      case 'School': return "Location Type (Class, Lab, Yard)";
      case 'Event': return "Location Type (Stage, Booth)";
      default: return "Location Type (Hall, Lab)";
    }
  }
}
