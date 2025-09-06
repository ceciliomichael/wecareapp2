import 'package:flutter/material.dart';

class BarangayDropdown extends StatelessWidget {
  final String? selectedBarangay;
  final List<String> barangayList;
  final ValueChanged<String?> onChanged;
  final String? label;
  final String? hint;

  const BarangayDropdown({
    super.key,
    required this.selectedBarangay,
    required this.barangayList,
    required this.onChanged,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? 'Barangay in Tagbilaran City',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBarangay,
              hint: Text(
                hint ?? 'Select Barangay',
                style: const TextStyle(color: Color(0xFF9E9E9E)),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1565C0)),
              isExpanded: true,
              items: barangayList.map((String barangay) {
                return DropdownMenuItem<String>(
                  value: barangay,
                  child: Text(barangay),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
