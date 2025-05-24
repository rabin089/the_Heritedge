import 'package:flutter/material.dart';

class DashboardStatsRow extends StatelessWidget {
  const DashboardStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: StatCard(title: 'Users', value: '1,234', icon: Icons.people),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Heritage Sites',
            value: '89',
            icon: Icons.landscape,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatCard(title: 'Events', value: '15', icon: Icons.event),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Pending Reviews',
            value: '23',
            icon: Icons.comment,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(value),
            Text(title),
          ],
        ),
      ),
    );
  }
}
