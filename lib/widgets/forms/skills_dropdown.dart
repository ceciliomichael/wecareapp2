import 'package:flutter/material.dart';

class SkillsDropdown extends StatelessWidget {
  final String? selectedSkill;
  final List<String> skillsList;
  final ValueChanged<String?> onChanged;

  const SkillsDropdown({
    super.key,
    required this.selectedSkill,
    required this.skillsList,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(
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
              value: selectedSkill,
              hint: const Text(
                'Select your primary skill',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1565C0)),
              isExpanded: true,
              items: skillsList.map((String skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
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
