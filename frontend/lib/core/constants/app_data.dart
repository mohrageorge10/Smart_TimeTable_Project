class AppData {
  static const List<String> allDays = [
    "Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
  ];

  //mode
  static const List<String> collegExcludedDays  = ["Friday"];
  static const List<String> hospitalExcludedDays = [];
  static const List<String> schoolExcludedDays   = ["Friday"];
  static const List<String> eventExcludedDays    = [];

  // ── College levels ──────────────────────────────────────
  static const List<String> universityLevels = [
    "First Year", "Second Year", "Third Year", "Fourth Year", "General",
  ];

  static const List<String> schoolLevels = [
    "Primary", "Preparatory", "Secondary",
  ];

  ///sections/classes(Collegemode)
  static List<String> getCollegeSections(String level) {
    switch (level) {
      case "First Year":
      case "Second Year":
      case "Third Year":
      case "Fourth Year":
        //→+
        return [
          "All General",
          ...List.generate(10, (i) => "Section ${i + 1}"),
        ];
      case "General":
        return ["All General"];
      default:
        return ["All General"];
    }
  }

  ///classes(Schoolmode)
  static List<String> getSchoolClasses(String level) {
    switch (level) {
      case "Primary":
        return List.generate(6, (i) => "Grade ${i + 1} (Primary)");
      case "Preparatory":
        return List.generate(3, (i) => "Grade ${i + 1} (Preparatory)");
      case "Secondary":
        return List.generate(3, (i) => "Grade ${i + 1} (Secondary)");
      default:
        return ["Grade 1"];
    }
  }

  static const List<String> academicYears = [
    "First Year", "Second Year", "Third Year", "Fourth Year", "General",
  ];

  static const List<String> audiences = [
    "Adults", "Kids", "Students", "Public",
  ];

  static const List<String> eventLocations = [
    "Cafe", "Restaurant", "Workspace", "College", "Club", "School",
  ];

  static const List<String> collegeLocations = ["Lecture Hall", "Lab", "Room"];

  static List<String> getTypes(String mode) {
    switch (mode) {
      case 'Hospital':
        return ["Morning Shift", "Night Shift", "Emergency", "Clinic"];
      case 'School':
        return ["Lecture", "Lab", "Activity"];
      case 'Event':
        return ["Workshop", "Keynote", "Panel Discussion", "Break"];
      default: // College
        return ["Lecture", "Section", "Lab"];
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
