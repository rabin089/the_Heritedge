import 'package:flutter/material.dart';

class HeritageSitesCard extends StatelessWidget {
  const HeritageSitesCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with real data source
    final sites = [
      {'name': 'Pashupatinath', 'location': 'Kathmandu'},
      {'name': 'Swayambhunath', 'location': 'Kathmandu'},
    ];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.landscape),
            title: Text('Heritage Sites'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sites.length,
              itemBuilder: (context, idx) {
                final site = sites[idx];
                return ListTile(
                  title: Text(site['name']!),
                  subtitle: Text(site['location']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      /* Implement view logic */
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
