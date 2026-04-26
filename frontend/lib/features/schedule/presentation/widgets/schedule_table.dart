import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_cubit.dart';
import 'package:frontend/features/schedule/logic/ScheduleCubit/schedule_state.dart';
import 'package:frontend/features/schedule/presentation/widgets/build_schedule_cell.dart';
import 'package:frontend/features/schedule/presentation/widgets/header_cell_table.dart';

class ScheduleTable extends StatelessWidget {
  const ScheduleTable({super.key});

  final List<String> days = const ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        
        if (state is ScheduleInitial) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_chart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "Enter data and click Generate to see the magic! ✨",
                    style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        } 
        
        else if (state is ScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        } 
        
        else if (state is ScheduleError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  // split numbered points onto separate lines
                  ...() {
                    final msg = state.message;
                    final parts = msg.split(RegExp(r'(?=\(\d+\))'));
                    return parts.map((part) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        part.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    )).toList();
                  }(),
                ],
              ),
            ),
          );
        } 
        
        else if (state is ScheduleLoaded) {
          final schedule = state.schedule;
          final cubit = context.read<ScheduleCubit>();
          final slots = cubit.calculatedSlots;

          if (slots.isEmpty) {
            return const Center(child: Text("No time slots calculated yet."));
          }

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            child: SizedBox(
              width: 1150, 
              child: Container(
                margin: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      0: const FixedColumnWidth(110.0),
                      for (int i = 1; i <= days.length; i++) i: const FixedColumnWidth(160.0),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                        children: [
                          _buildHeaderCell("Time \\ Day", context),
                          ...days.map((day) => _buildHeaderCell(day, context)),
                        ],
                      ),
                      ...slots.asMap().entries.map((entry) {
                        final slot = entry.value;
                        return TableRow(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              color: Colors.grey.shade50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(slot["Slot"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text("${slot["Start"]}\n↓\n${slot["End"]}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            ...days.map((day) {
                              final items = _getCoursesForTimeAndDay(schedule, day, slot["Slot"]!);
                              
                              if (items.isNotEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: items.map((item) => _buildScheduleCell(item, context)).toList(),
                                  ),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: Text("-", style: TextStyle(color: Colors.grey))),
                                );
                              }
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHeaderCell(String text, BuildContext context) {
    return HeaderCellTable(text: text);
  }

  Widget _buildScheduleCell(dynamic item, BuildContext context) {
    final String name = (item is Map) ? (item['name'] ?? '') : (item.name ?? '');
    final String person = (item is Map) ? (item['person'] ?? '') : (item.person ?? '');
    final String room = (item is Map) ? (item['room'] ?? '') : (item.room ?? '');

    return BuildScheduleCell(name: name, person: person, room: room);
  }

  List<dynamic> _getCoursesForTimeAndDay(List<dynamic> schedule, String day, String slotName) {
    return schedule.where((element) {
      if (element is Map) {
        return element['day'] == day && element['slot'] == slotName;
      }
      return element.day == day && element.slot == slotName;
    }).toList();
  }
}