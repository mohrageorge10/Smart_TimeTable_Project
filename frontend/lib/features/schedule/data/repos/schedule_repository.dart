import 'package:dio/dio.dart';
import '../models/schedule_item.dart';

class ScheduleRepository {
  final Dio _dio = Dio();
  final String _baseUrl = "http://127.0.0.1:8000"; 

  Future<List<ScheduleItem>> generateSchedule(Map<String, dynamic> data) async {
    final response = await _dio.post("$_baseUrl/generate-schedule", data: data);
    
    if (response.statusCode == 200) {
      List<dynamic> schedule = response.data['schedule'];
      return schedule.map((item) => ScheduleItem.fromJson(item)).toList();
    } else {
      throw Exception("Failed to generate schedule");
    }
  }
}