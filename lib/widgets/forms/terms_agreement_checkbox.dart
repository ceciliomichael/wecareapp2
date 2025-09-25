import 'package:flutter/material.dart';
import '../ui/terms_conditions_dialog.dart';

class TermsAgreementCheckbox extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool> onChanged;

  const TermsAgreementCheckbox({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  Future<void> _showTermsDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const TermsConditionsDialog(),
    );
    
    if (result == true) {
      onChanged(true);
    }
  }

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
            onTap: () => _showTermsDialog(context),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: const TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF546E7A),
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1565C0),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
