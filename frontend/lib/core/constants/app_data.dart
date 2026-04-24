class AppData {
  static const List<String> days = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
  ];
  static const List<String> academicYears = [
    "First Year",
    "Second Year",
    "Third Year",
    "Fourth Year",
    "General",
  ];

  static const List<String> audiences = [
    "Adults",
    "Kids",
    "Students",
    "Public",
  ];

  static const List<String> eventLocations = [
    "Cafe",
    "Restaurant",
    "Workspace",
    "College",
    "Club",
    "School",
  ];

  static const List<String> collegeLocations = ["Lecture Hall", "Lab", "Room"];

  static List<String> getTypes(String mode) {
    switch (mode) {
      case 'Hospital':
        return ["Morning Shift", "Night Shift", "Emergency", "Clinic"];
      case 'School':
        return ["Primary", "Secondary", "Preparatory"];
      case 'Event':
        return ["Workshop", "Keynote", "Panel Discussion", "Break"];
      default: // College
        return ["Lecture", "Section"];
    }
  }
  static String getAcademicYearLabel(String mode) {
    switch (mode) {
      case 'Event':
        return "Target Audience";
      default: // College
        return "Academic Year";
    }
  }

  static List<String> getSpecialties(String mode) {
    switch (mode) {
      case 'Hospital':
        return ["Eyes", "Internal", "Surgery", "Dental", "General"];
      case 'School':
        return ["Primary", "Preparatory", "Secondary"];
      case 'Event':
        return ["Technology", "Business", "Medical", "Design"];
      default: // College
        return ["CS", "IS", "IT", "General"];
    }
  }
}
