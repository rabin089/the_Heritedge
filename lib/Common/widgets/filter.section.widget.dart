import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class FilterSectionWidget extends StatefulWidget {
  final void Function({
  required String region,
  required String category,
  required List<String> tags,
  }) onApply;

  const FilterSectionWidget({super.key, required this.onApply});

  @override
  State<FilterSectionWidget> createState() => _FilterSectionWidgetState();
}

class _FilterSectionWidgetState extends State<FilterSectionWidget> {
  String selectedRegion = "All";
  String selectedCategory = "All";
  List<String> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filter", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: _buildDropdown(
                    "Region",
                    [
                      "All",
                      "Bagmati",
                      "Gandaki",
                      "Lumbini",
                      "Karnali",
                      "Sudurpashchim",
                      "Koshi",
                      "Madhesh",
                    ],
                    selectedRegion,
                        (val) => setState(() => selectedRegion = val!),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _buildDropdown(
                    "Category",
                    [
                      "All",
                      'Temple',
                      'Monument',
                      'Palace',
                      'Fort',
                      'Museum',
                      'Archaeological Site',
                      'Religious Site',
                      'Cultural Heritage',
                      'Natural Heritage',
                      'Other',
                    ],
                    selectedCategory,
                        (val) => setState(() => selectedCategory = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRegion = "All";
                      selectedCategory = "All";
                      selectedTags.clear();
                    });
                    widget.onApply(region: "All", category: "All", tags: []);
                  },
                  child: const Text("Clear", style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(50, 28),
                  ),
                  onPressed: () {
                    widget.onApply(
                      region: selectedRegion,
                      category: selectedCategory,
                      tags: selectedTags.map((e) => e.toLowerCase()).toList(),
                    );
                  },
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      List<String> options,
      String currentValue,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField2<String>(
      value: currentValue,
      isDense: true,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 180,
        elevation: 2,
        padding: EdgeInsets.zero,
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      items: options
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(fontSize: 12, color: Colors.black)),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}
