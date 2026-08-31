import 'package:flutter/material.dart';

import '../../../data/models/programme_model.dart';

class ProgrammeCard extends StatelessWidget {
  final ProgrammeModel programme;
  final VoidCallback onTap;

  const ProgrammeCard({
    super.key,
    required this.programme,
    required this.onTap,
  });

  Color getStatusColor() {
    switch (programme.status.toLowerCase()) {
      case 'active':
        return Colors.green;

      case 'completed':
        return Colors.blue;

      case 'draft':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        title: Text(
          programme.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                programme.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              Row(
                children: [

                  const Icon(Icons.calendar_today,size:16),

                  const SizedBox(width:6),

                  Text("Season ${programme.season}"),

                  const Spacer(),

                  Chip(
                    backgroundColor: getStatusColor(),
                    label: Text(
                      programme.status,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}