// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleItem _$ScheduleItemFromJson(Map<String, dynamic> json) => ScheduleItem(
      name: json['name'] as String,
      person: json['person'] as String,
      students: (json['students'] as num).toInt(),
      available_days: (json['available_days'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: json['type'] as String,
      day: json['day'] as String?,
      slot: json['slot'] as String?,
      room: json['room'] as String?,
    );

Map<String, dynamic> _$ScheduleItemToJson(ScheduleItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'person': instance.person,
      'students': instance.students,
      'available_days': instance.available_days,
      'type': instance.type,
      'day': instance.day,
      'slot': instance.slot,
      'room': instance.room,
    };
