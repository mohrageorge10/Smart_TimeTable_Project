
import 'package:flutter/material.dart';

class BuildScheduleCell extends StatelessWidget {
  const BuildScheduleCell({
    super.key,
    required this.name,
    required this.person,
    required this.room,
  });

  final String name;
  final String person;
  final String room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              name, 
              textAlign: TextAlign.center, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).primaryColor)
            ),
          ),
          const Divider(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 4),
              Expanded(child: Text(person, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.meeting_room, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 4),
              Expanded(child: Text(room, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }
}
