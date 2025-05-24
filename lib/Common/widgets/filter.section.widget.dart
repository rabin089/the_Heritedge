import 'package:flutter/material.dart';

class FilterSectionWidget extends StatelessWidget {
  const FilterSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildDropdown("Region", ["All", "Bagmati", "Gandaki"])),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Category", ["All", "Temple", "Museum"])),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: ["UNESCO", "Buddhist", "Medieval", "Hindu", "Pagoda"]
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return DropdownButtonFormField(
      value: options.first,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }
}
