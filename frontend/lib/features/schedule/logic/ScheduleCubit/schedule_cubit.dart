import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/database/schedule_local_service.dart';
import 'package:frontend/core/network/schedule_api_service.dart';
import 'package:frontend/core/utils/mock_data_service.dart';
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
  String? selectedSection;
  List<String> itemAvailableDays = [];

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
    addedLocations.clear();
    addedItems.clear();
    calculatedSlots.clear();

    final mockData = MockDataService.getMockDataForMode(currentMode);

    startTime = mockData["startTime"] as String;
    numberOfSlots = mockData["numberOfSlots"] as int;
    slotDuration = mockData["slotDuration"] as int;
    breakDuration = mockData["breakDuration"] as int;

    addedLocations = (mockData["locations"] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    addedItems = (mockData["items"] as Map).map(
      (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)),
    );

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
      if (config.hasDynamicSection && selectedSection != null)
        config.sectionLabel!: selectedSection,
      "available_days": List<String>.from(itemAvailableDays),
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

  List<String> selectedDays = [];

  void generateSchedule() async {
    emit(ScheduleLoading());

    try {
      List<String> days = selectedDays.isNotEmpty
          ? selectedDays
          : [
              'Saturday',
              'Sunday',
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
            ];

      List<String> timeslots = calculatedSlots.map((s) => s["Slot"]!).toList();

      List<Map<String, dynamic>> itemsList = [];
      addedItems.forEach((name, details) {
        final config = ModeRepository.modes[currentMode]!;

        final int students =
            int.tryParse(details["Capacity"]?.toString() ?? '0') ?? 0;
        final String batch =
            details[config.academicYearLabel ?? "Academic Year"]?.toString() ??
            "general";
        final String? section = config.hasDynamicSection
            ? details[config.sectionLabel]?.toString()
            : null;

        List<String> safeAvailableDays = [];
        if (details["available_days"] != null) {
          safeAvailableDays = (details["available_days"] as List)
              .map((e) => e.toString())
              .toList();
        }

        itemsList.add({
          "name": name,
          "person": details[config.personLabel] ?? "Unknown",
          "students": students,
          "available_days": safeAvailableDays,
          "type": details["Type"]?.toString() ?? "Lecture",
          "batch": batch,
          "section": ?section,
        });
      });

      Map<String, dynamic> roomsInfo = {};
      for (var loc in addedLocations) {
        roomsInfo[loc["name"]] = {
          "capacity": loc["capacity"] ?? 0,
          "type": loc["type"] ?? "Room",
        };
      }
      // Hospital has no physical locations — inject a virtual unlimited room
      // so the solver can assign shifts without room constraints
      if (roomsInfo.isEmpty) {
        roomsInfo["Virtual Room"] = {"capacity": 99999, "type": "any"};
      }

      Map<String, dynamic> requestData = {
        "items": itemsList,
        "days": days,
        "timeslots": timeslots,
        "rooms_info": roomsInfo,
      };
      print("====== REQUEST DATA ======");
      print(requestData);
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
