import 'package:frontend/features/schedule/data/repos/mode_repo.dart';

class MockDataService {
  static Map<String, dynamic> getMockDataForMode(String mode) {
    final config = ModeRepository.modes[mode] ?? ModeRepository.modes['College']!;

    switch (mode) {
      // ══════════════════════════════════════════════════════
      case 'College':
        return {
          "startTime":    "08:00 AM",
          "numberOfSlots": 5,
          "slotDuration":  90,
          "breakDuration": 15,
          "locations": [
            {"name": "Main Hall A",   "capacity": 350, "type": "Lecture Hall"},
            {"name": "Main Hall B",   "capacity": 300, "type": "Lecture Hall"},
            {"name": "Lab CS-1",      "capacity": 30,  "type": "Lab"},
            {"name": "Lab CS-2",      "capacity": 30,  "type": "Lab"},
          ],
          "items": {
            //—ThirdYear
            "Operating Systems": {
              config.nameLabel:    "Operating Systems",
              config.personLabel:  "Dr. Ahmed Hassan",
              "Capacity":          "280",
              "Type":              "Lecture",
              "Level":             "Third Year",
              "Section":           "All General",
              "available_days":    ["Sunday", "Tuesday"],
            },
            "Artificial Intelligence": {
              config.nameLabel:    "Artificial Intelligence",
              config.personLabel:  "Dr. Sara Mahmoud",
              "Capacity":          "280",
              "Type":              "Lecture",
              "Level":             "Third Year",
              "Section":           "All General",
              "available_days":    ["Monday", "Wednesday"],
            },
            "Software Engineering": {
              config.nameLabel:    "Software Engineering",
              config.personLabel:  "Dr. Khaled Nabil",
              "Capacity":          "280",
              "Type":              "Lecture",
              "Level":             "Third Year",
              "Section":           "All General",
              "available_days":    ["Saturday", "Thursday"],
            },
            //—ThirdYear
            "OS Section 1": {
              config.nameLabel:    "OS Section 1",
              config.personLabel:  "Eng. Ali Saad",
              "Capacity":          "25",
              "Type":              "Section",
              "Level":             "Third Year",
              "Section":           "Section 1",
              "available_days":    ["Saturday"],
            },
            "OS Section 2": {
              config.nameLabel:    "OS Section 2",
              config.personLabel:  "Eng. Ali Saad",
              "Capacity":          "25",
              "Type":              "Section",
              "Level":             "Third Year",
              "Section":           "Section 2",
              "available_days":    ["Sunday"],
            },
            // Second Year
            "Data Structures": {
              config.nameLabel:    "Data Structures",
              config.personLabel:  "Dr. Mona Fawzy",
              "Capacity":          "300",
              "Type":              "Lecture",
              "Level":             "Second Year",
              "Section":           "All General",
              "available_days":    ["Saturday", "Monday"],
            },
          },
        };

      // ══════════════════════════════════════════════════════
      case 'Hospital':
        return {
          "startTime":     "07:00 AM",
          "numberOfSlots": 3,
          "slotDuration":  480,
          "breakDuration": 0,
          "locations": <Map<String, dynamic>>[],   //Hospitallocations
          "items": {
            "Morning Round": {
              config.nameLabel:   "Morning Round",
              config.personLabel: "Dr. House",
              "Type":             "Morning Shift",
              "available_days":   ["Saturday", "Sunday", "Monday", "Tuesday"],
            },
            "Night Emergency": {
              config.nameLabel:   "Night Emergency",
              config.personLabel: "Dr. Wilson",
              "Type":             "Night Shift",
              "available_days":   ["Wednesday", "Thursday"],
            },
            "Dental Clinic": {
              config.nameLabel:   "Dental Clinic",
              config.personLabel: "Dr. Amira",
              "Type":             "Clinic",
              "available_days":   ["Saturday", "Monday", "Wednesday"],
            },
            "ER Coverage": {
              config.nameLabel:   "ER Coverage",
              config.personLabel: "Dr. James",
              "Type":             "Emergency",
              "available_days":   ["Sunday", "Tuesday", "Thursday"],
            },
          },
        };

      // ══════════════════════════════════════════════════════
      case 'School':
        return {
          "startTime":     "07:30 AM",
          "numberOfSlots": 7,
          "slotDuration":  45,
          "breakDuration": 15,
          "locations": [
            {"name": "Class 1-A",     "capacity": 35, "type": "Room"},
            {"name": "Class 1-B",     "capacity": 35, "type": "Room"},
            {"name": "Class 2-A",     "capacity": 40, "type": "Room"},
            {"name": "Science Lab",   "capacity": 30, "type": "Lab"},
          ],
          "items": {
            // Primary — Grade 1
            "Mathematics": {
              config.nameLabel:    "Mathematics",
              config.personLabel:  "Mr. Ahmed",
              "Capacity":          "30",
              "Type":              "Lecture",
              "Level":             "Primary",
              "Class":             "Grade 1 (Primary)",
              "available_days":    ["Saturday", "Monday", "Wednesday"],
            },
            "Arabic Language": {
              config.nameLabel:    "Arabic Language",
              config.personLabel:  "Mrs. Hoda",
              "Capacity":          "30",
              "Type":              "Lecture",
              "Level":             "Primary",
              "Class":             "Grade 1 (Primary)",
              "available_days":    ["Sunday", "Tuesday", "Thursday"],
            },
            // Primary — Grade 2
            "Science": {
              config.nameLabel:    "Science",
              config.personLabel:  "Mrs. Sara",
              "Capacity":          "28",
              "Type":              "Lab",
              "Level":             "Primary",
              "Class":             "Grade 2 (Primary)",
              "available_days":    ["Sunday", "Tuesday"],
            },
            // Preparatory
            "Physics": {
              config.nameLabel:    "Physics",
              config.personLabel:  "Mr. Youssef",
              "Capacity":          "32",
              "Type":              "Lecture",
              "Level":             "Preparatory",
              "Class":             "Grade 1 (Preparatory)",
              "available_days":    ["Saturday", "Monday", "Thursday"],
            },
          },
        };

      // ══════════════════════════════════════════════════════
      case 'Event':
        return {
          "startTime":     "09:00 AM",
          "numberOfSlots": 5,
          "slotDuration":  60,
          "breakDuration": 20,
          "locations": [
            {"name": "Main Auditorium", "capacity": 500, "type": "College"},
            {"name": "Workshop Room A", "capacity": 40,  "type": "Workspace"},
            {"name": "Workshop Room B", "capacity": 40,  "type": "Workspace"},
            {"name": "Networking Cafe", "capacity": 100, "type": "Cafe"},
          ],
          "items": {
            "Opening Keynote": {
              config.nameLabel:    "Opening Keynote",
              config.personLabel:  "Dr. Elon Speaker",
              "Capacity":          "450",
              "Type":              "Keynote",
              config.academicYearLabel!: "Students",
              "available_days":    ["Saturday"],
            },
            "AI Workshop": {
              config.nameLabel:    "AI Workshop",
              config.personLabel:  "Eng. Sara AI",
              "Capacity":          "35",
              "Type":              "Workshop",
              config.academicYearLabel!: "Students",
              "available_days":    ["Saturday"],
            },
            "Panel: Future of Tech": {
              config.nameLabel:    "Panel: Future of Tech",
              config.personLabel:  "Various Speakers",
              "Capacity":          "200",
              "Type":              "Panel Discussion",
              config.academicYearLabel!: "Public",
              "available_days":    ["Saturday"],
            },
            "Lunch Break": {
              config.nameLabel:    "Lunch Break",
              config.personLabel:  "—",
              "Capacity":          "500",
              "Type":              "Break",
              config.academicYearLabel!: "Public",
              "available_days":    ["Saturday"],
            },
          },
        };

      // ══════════════════════════════════════════════════════
      default:
        return {
          "startTime":     "08:00 AM",
          "numberOfSlots": 5,
          "slotDuration":  60,
          "breakDuration": 10,
          "locations":     <Map<String, dynamic>>[],
          "items":         <String, Map<String, dynamic>>{},
        };
    }
  }
}
