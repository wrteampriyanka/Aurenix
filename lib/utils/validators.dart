class Validators {
  Validators._();

  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'This field is required' : null;

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    return regex.hasMatch(value) ? null : 'Enter a valid email';
  }
}
