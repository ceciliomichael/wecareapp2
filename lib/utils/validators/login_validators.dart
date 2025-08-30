class LoginValidators {
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }

    // Check if it's a phone number format
    if (value.startsWith('+63')) {
      if (!RegExp(r'^\+63\s?\d{10}$').hasMatch(value.replaceAll(' ', ''))) {
        return 'Please enter a valid phone number';
      }
      return null;
    }

    // Check if it's an email format
    if (value.contains('@')) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
      return null;
    }

    // If it's all digits, assume it's a phone number without +63
    if (RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please include +63 before your phone number';
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
