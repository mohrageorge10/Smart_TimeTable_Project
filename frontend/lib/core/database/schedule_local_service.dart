import 'package:hive/hive.dart';

class ScheduleLocalService {
  final String boxName = 'scheduleBox';
  final String scheduleKey = 'savedSchedule';

  Future<void> saveSchedule(List<dynamic> schedule) async {
    var box = Hive.box(boxName);
    await box.put(scheduleKey, schedule);
  }

  List<dynamic>? loadSchedule() {
    var box = Hive.box(boxName);
    return box.get(scheduleKey);
  }

  Future<void> clearSchedule() async {
    var box = Hive.box(boxName);
    await box.delete(scheduleKey);
  }
}