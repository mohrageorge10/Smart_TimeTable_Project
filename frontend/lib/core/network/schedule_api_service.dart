import 'package:dio/dio.dart';

class ScheduleApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<dynamic>> fetchSchedule(Map<String, dynamic> requestData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/generate-schedule',
        data: requestData,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['schedule'];
      } else {
        throw Exception("Failed to generate schedule");
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to connect to AI Server.";
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      throw Exception(errorMessage); 
    } catch (e) {
      throw Exception("Unexpected Error: $e");
    }
  }
}