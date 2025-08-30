import 'package:flutter/material.dart';

class FileUploadField extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback onTap;
  final String placeholder;

  const FileUploadField({
    super.key,
    required this.label,
    required this.fileName,
    required this.onTap,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: fileName != null 
                    ? const Color(0xFF4CAF50) 
                    : const Color(0xFF9E9E9E),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  fileName != null 
                      ? Icons.check_circle 
                      : Icons.upload_file,
                  color: fileName != null 
                      ? const Color(0xFF4CAF50) 
                      : const Color(0xFF9E9E9E),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? placeholder,
                    style: TextStyle(
                      color: fileName != null 
                          ? const Color(0xFF4CAF50) 
                          : const Color(0xFF9E9E9E),
                      fontWeight: fileName != null 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
