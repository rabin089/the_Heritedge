import 'package:flutter/material.dart';

class SiteActionBottomSheet extends StatelessWidget {
  final String siteName;
  final VoidCallback onSave;
  final VoidCallback onViewDetails;

  const SiteActionBottomSheet({
    super.key,
    required this.siteName,
    required this.onSave,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              siteName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.bookmark),
                  label: const Text("Save for Later"),
                ),
                ElevatedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info),
                  label: const Text("View Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
