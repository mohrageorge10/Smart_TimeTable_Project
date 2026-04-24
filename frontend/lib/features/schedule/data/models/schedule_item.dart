import 'package:json_annotation/json_annotation.dart';

part 'schedule_item.g.dart'; // هذا الملف سيتم توليده أوتوماتيكياً

@JsonSerializable()
class ScheduleItem {
  final String name;
  final String person;
  final int students;
  final List<String> available_days;
  final String type;
  
  final String? day;
  final String? slot;
  final String? room;

  ScheduleItem({
    required this.name,
    required this.person,
    required this.students,
    required this.available_days,
    required this.type,
    this.day,
    this.slot,
    this.room,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => _$ScheduleItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$ScheduleItemToJson(this);
}