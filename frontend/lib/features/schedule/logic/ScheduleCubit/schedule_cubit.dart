import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/database/schedule_local_service.dart';
import 'package:frontend/core/network/schedule_api_service.dart';
import 'package:frontend/features/schedule/data/repos/mode_repo.dart';
import 'package:frontend/features/schedule/data/repos/schedule_repository.dart'; 
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;
  
  final ScheduleApiService _apiService = ScheduleApiService();
  final ScheduleLocalService _localService = ScheduleLocalService();

  String currentMode = 'College';

  String courseName = '';
  String lecturerName = '';
  int studentsCount = 0;
  String? selectedType;
  String? selectedSpecialty;
  String? selectedYear;
  String? targetAudience;

  int numberOfSlots = 0;
  int slotDuration = 0;
  String startTime = '';
  int breakDuration = 0;

  String locationName = '';
  int locationCapacity = 0;
  String locationType = '';

  Map<String, Map<String, dynamic>> addedItems = {};
  List<Map<String, dynamic>> addedLocations = [];
  List<Map<String, String>> calculatedSlots = [];

  ScheduleCubit(this.repository) : super(ScheduleInitial()) {
    loadSavedSchedule(); 
  }

  void refreshUI() {
    emit(ScheduleLoading());
    emit(ScheduleInitial());
  }

  void calculateSlots() {
    calculatedSlots.clear();
    if (startTime.isEmpty || numberOfSlots <= 0 || slotDuration <= 0) {
      refreshUI();
      return;
    }

    try {
      final regex = RegExp(r'(\d+):(\d+)\s*(AM|PM|am|pm)?');
      final match = regex.firstMatch(startTime);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String? amPm = match.group(3)?.toUpperCase();

        if (amPm == 'PM' && hour < 12) hour += 12;
        if (amPm == 'AM' && hour == 12) hour = 0;

        DateTime currentTime = DateTime(2000, 1, 1, hour, minute);

        for (int i = 1; i <= numberOfSlots; i++) {
          DateTime endTime = currentTime.add(Duration(minutes: slotDuration));

          String formatTime(DateTime time) {
            String h = (time.hour % 12 == 0 ? 12 : time.hour % 12).toString();
            String m = time.minute.toString().padLeft(2, '0');
            String p = time.hour >= 12 ? "PM" : "AM";
            return "$h:$m $p";
          }

          calculatedSlots.add({
            "Slot": "Slot $i",
            "Start": formatTime(currentTime),
            "End": formatTime(endTime),
          });

          currentTime = endTime.add(Duration(minutes: breakDuration));
        }
      }
    } catch (e) {}

    refreshUI();
  }

  void fillMockData() {
    startTime = "08:00 AM";
    numberOfSlots = 5; 
    slotDuration = 90; 
    breakDuration = 10;
    addedLocations = [
      {"name": "مدرج 1", "capacity": 500, "type": "Lecture Hall"},
      {"name": "مدرج 2", "capacity": 500, "type": "Lecture Hall"},
      {"name": "مدرج 3", "capacity": 500, "type": "Lecture Hall"},
      {"name": "معمل حاسبات 1", "capacity": 50, "type": "Computer Lab"}, // معمل احتياطي لو فيه سكاشن
    ];

    final config = ModeRepository.modes[currentMode] ?? ModeRepository.modes['College']!;
    
    addedItems = {
      "نظم التشغيل": {config.nameLabel: "نظم التشغيل", config.personLabel: "د/ حندوسة - د/ العروسي", "Capacity": "300", "Type": "Lecture"},
      "الذكاء الاصطناعي": {config.nameLabel: "الذكاء الاصطناعي", config.personLabel: "د/ سارة المتولي", "Capacity": "300", "Type": "Lecture"},
      "تصميم لغات الحاسب": {config.nameLabel: "تصميم لغات الحاسب", config.personLabel: "د/ رشا صقر - د/ داليا", "Capacity": "300", "Type": "Lecture"},
      "معالجة الإشارات": {config.nameLabel: "معالجة الإشارات الرقمية", config.personLabel: "د/ فاطمة الزهراء", "Capacity": "300", "Type": "Lecture"},
      "هندسة برمجيات": {config.nameLabel: "هندسة برمجيات", config.personLabel: "د/ أمل - د/ حمدي", "Capacity": "300", "Type": "Lecture"},
    };

    calculateSlots(); 
  }

  void addItemToList() {
    if (courseName.isEmpty) return;
    final config = ModeRepository.modes[currentMode]!;
    final academicOrAudienceValue = (currentMode == 'Event')
        ? targetAudience
        : selectedYear;

    addedItems[courseName] = {
      config.nameLabel: courseName,
      config.personLabel: lecturerName,
      if (config.hasCapacity) "Capacity": studentsCount.toString(),
      if (selectedType != null) "Type": selectedType,
      if (config.hasAcademicYear && academicOrAudienceValue != null)
        config.academicYearLabel!: academicOrAudienceValue,
    };

    refreshUI();
  }

  void addLocationToList() {
    if (locationName.isEmpty) return;
    addedLocations.add({
      "name": locationName,
      "capacity": locationCapacity,
      "type": locationType,
    });
    locationName = '';
    locationCapacity = 0;

    refreshUI();
  }

  void generateSchedule() async {
    emit(ScheduleLoading());

    try {
      List<String> days = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];
      List<String> timeslots = calculatedSlots.map((s) => s["Slot"]!).toList();

      List<Map<String, dynamic>> itemsList = [];
      addedItems.forEach((name, details) {
        final config = ModeRepository.modes[currentMode]!;
        itemsList.add({
          "name": name,
          "person": details[config.personLabel] ?? "Unknown",
          "students": int.tryParse(details["Capacity"]?.toString() ?? '0') ?? 0,
          "available_days": [], 
          "type": details["Type"]?.toString() ?? "Lecture",
        });
      });

      Map<String, dynamic> roomsInfo = {};
      for (var loc in addedLocations) {
        roomsInfo[loc["name"]] = {
          "capacity": loc["capacity"] ?? 0,
          "type": loc["type"] ?? "Room",
        };
      }

      Map<String, dynamic> requestData = {
        "items": itemsList,
        "days": days,
        "timeslots": timeslots,
        "rooms_info": roomsInfo,
      };

      final finalSchedule = await _apiService.fetchSchedule(requestData);

      await _localService.saveSchedule(finalSchedule);

      emit(ScheduleLoaded(finalSchedule));

    } catch (e) {
      emit(ScheduleError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  void loadSavedSchedule() {
    var savedSchedule = _localService.loadSchedule();
    
    if (savedSchedule != null) {
      emit(ScheduleLoaded(List<dynamic>.from(savedSchedule)));
    }
  }
}