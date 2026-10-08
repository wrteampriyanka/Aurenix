import 'package:get/get.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Form field validators. Every message is a translation key so it follows
/// the app's language; a raw English string here shows up untranslated in
/// hi and ar.
class Validators {
  Validators._();

  static String? required(String? value) =>
      (value == null || value.trim().isEmpty)
      ? AppStrings.validationRequired.tr
      : null;

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationEmailRequired.tr;
    }
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    return regex.hasMatch(value) ? null : AppStrings.validationEmailInvalid.tr;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationPasswordRequired.tr;
    }
    return value.length < 8 ? AppStrings.validationPasswordShort.tr : null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationConfirmRequired.tr;
    }
    return value == password ? null : AppStrings.validationPasswordMismatch.tr;
  }
}
