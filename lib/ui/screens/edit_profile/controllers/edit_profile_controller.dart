import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../utils/validators.dart';

/// Editable user details, passed in as the route argument and returned
/// from the screen when the changes are saved.
class ProfileDetails {
  const ProfileDetails({
    required this.name,
    required this.email,
    this.genderKey,
    this.age,
  });

  final String name;
  final String email;

  /// One of [EditProfileController.genderKeys].
  final String? genderKey;
  final int? age;
}

class EditProfileController extends GetxController {
  static const genderKeys = ['gender_male', 'gender_female', 'gender_other'];

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();

  final gender = RxnString();
  final isNoticeVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments case final ProfileDetails details) {
      nameController.text = details.name;
      emailController.text = details.email;
      gender.value = details.genderKey;
      ageController.text = details.age?.toString() ?? '';
    }
  }

  void onGenderChanged(String? value) => gender.value = value;

  void dismissNotice() => isNoticeVisible.value = false;

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) return null;
    final age = int.tryParse(value);
    return (age == null || age < 1 || age > 120) ? 'Enter a valid age' : null;
  }

  String? validateName(String? value) => Validators.required(value);

  void onSave() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    // TODO: persist the changes once the profile API is wired up.
    Get.back(
      result: ProfileDetails(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        genderKey: gender.value,
        age: int.tryParse(ageController.text),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    super.onClose();
  }
}
