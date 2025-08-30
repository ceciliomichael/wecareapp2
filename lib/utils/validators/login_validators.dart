class LoginValidators {
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }

    // Check if it's a phone number format (starts with +63)
    if (value.startsWith('+63')) {
      final phoneNumber = value.substring(3); // Remove +63 prefix
      
      // Remove any non-digit characters from phone number
      final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      if (digitsOnly.length != 10) {
        return 'Please enter a valid 10-digit phone number';
      }
      return null;
    }

    // Check if it's an email format (contains @)
    if (value.contains('@')) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
      return null;
    }

    // If it's just digits (without +63), check if it's 10 digits
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == 10 && digitsOnly == value) {
      return 'Phone number should include +63 prefix';
    }

    return 'Please enter a valid email or phone number';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
