import 'package:flutter/material.dart';

class FileUploadField extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback? onTap;
  final String placeholder;
  final bool isLoading;

  const FileUploadField({
    super.key,
    required this.label,
    required this.fileName,
    required this.onTap,
    required this.placeholder,
    this.isLoading = false,
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
          onTap: isLoading ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLoading 
                  ? const Color(0xFFF0F0F0)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLoading
                    ? const Color(0xFFBDBDBD)
                    : fileName != null 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFF9E9E9E),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                    ),
                  )
                else
                  Icon(
                    fileName != null 
                        ? Icons.check_circle 
                        : Icons.image_outlined,
                    color: fileName != null 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFF9E9E9E),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? placeholder,
                    style: TextStyle(
                      color: isLoading
                          ? const Color(0xFF9E9E9E)
                          : fileName != null 
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
