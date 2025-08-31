import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmailPhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color? themeColor;

  const EmailPhoneTextField({
    super.key,
    required this.controller,
    this.validator,
    this.themeColor,
  });

  @override
  State<EmailPhoneTextField> createState() => _EmailPhoneTextFieldState();
}

class _EmailPhoneTextFieldState extends State<EmailPhoneTextField> {
  bool _isPhoneMode = false;
  final TextEditingController _phoneController = TextEditingController();

  Color get _themeColor => widget.themeColor ?? const Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    // Listen to phone controller changes and update main controller
    _phoneController.addListener(_updateMainController);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updateMainController() {
    if (_isPhoneMode) {
      // Combine +63 with phone number
      final phoneNumber = _phoneController.text;
      widget.controller.text = phoneNumber.isNotEmpty ? '+63$phoneNumber' : '';
    }
  }

  void _toggleInputMode(bool isPhone) {
    setState(() {
      _isPhoneMode = isPhone;
      
      if (isPhone) {
        // If switching to phone mode, clear the main controller and reset phone controller
        final currentText = widget.controller.text;
        if (currentText.startsWith('+63')) {
          _phoneController.text = currentText.substring(3);
        } else {
          _phoneController.text = '';
          widget.controller.clear();
        }
      } else {
        // If switching to email mode, clear both controllers
        widget.controller.clear();
        _phoneController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle Buttons
          Row(
            children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _toggleInputMode(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isPhoneMode ? _themeColor : Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    border: Border.all(
                      color: !_isPhoneMode ? _themeColor : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: !_isPhoneMode ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _toggleInputMode(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isPhoneMode ? _themeColor : Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border.all(
                      color: _isPhoneMode ? _themeColor : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Phone Number',
                      style: TextStyle(
                        color: _isPhoneMode ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          ),
          
          const SizedBox(height: 16),

          // Input Field (email or phone)
          _isPhoneMode 
              ? _buildPhoneInput()
              : _buildEmailInput(),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      // Pass combined value (+63 + digits) to validator so it won't complain
      validator: (raw) => widget.validator?.call(
        (raw == null || raw.isEmpty) ? '' : '+63$raw',
      ),
      decoration: InputDecoration(
        hintText: 'Enter 10-digit number',
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        prefixIcon: Container(
          width: 80,
          alignment: Alignment.center,
          child: Text(
            '+63',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _themeColor,
            ),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _themeColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        errorStyle: const TextStyle(fontSize: 12, height: 1.2),
      ),
    );
  }

  Widget _buildEmailInput() {
    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.emailAddress,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: _themeColor, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: _themeColor, width: 2),
          ),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFF9E9E9E),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(fontSize: 12, height: 1.2),
        ),
      ),
    );
  }
}
