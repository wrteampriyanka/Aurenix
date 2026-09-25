class Validators {
  Validators._();

  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'This field is required' : null;
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    return regex.hasMatch(value) ? null : 'Enter a valid email';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return value.length < 8 ? 'Use at least 8 characters' : null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    return value == password ? null : 'Passwords do not match';
  }
}
