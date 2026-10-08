/// Why the code is being verified, which decides where Continue leads.
enum OtpPurpose { register, resetPassword }

/// Route arguments for the OTP screen.
class OtpArgs {
  const OtpArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}
