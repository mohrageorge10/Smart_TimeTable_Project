import 'package:flutter/material.dart';

class DetailsSectionCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;

  const DetailsSectionCard({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(),
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${e.key}: ", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  Expanded(
                    child: Text(
                      e.value.toString(), 
                      style: const TextStyle(fontSize: 16)
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}