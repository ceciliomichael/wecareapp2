import 'package:flutter/material.dart';

class TermsAgreementCheckbox extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool> onChanged;

  const TermsAgreementCheckbox({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isAgreed,
          onChanged: (bool? value) => onChanged(value ?? false),
          activeColor: const Color(0xFF1565C0),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!isAgreed),
            child: const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF546E7A),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
