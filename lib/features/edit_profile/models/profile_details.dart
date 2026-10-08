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
