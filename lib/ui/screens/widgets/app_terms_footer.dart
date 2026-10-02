import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import 'custom_text.dart';

/// "By clicking continue you agree to our Terms & Conditions and Privacy
/// Policy." footer shown at the bottom of the auth screens.
class AppTermsFooter extends StatelessWidget {
  const AppTermsFooter({
    super.key,
    required this.termsRecognizer,
    required this.privacyRecognizer,
  });

  final GestureRecognizer termsRecognizer;
  final GestureRecognizer privacyRecognizer;

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: context.color.textNatural,
      decoration: TextDecoration.underline,
      decorationColor: context.color.textNatural,
    );

    return CustomText(
      '',
      fontSize: 12,
      textAlign: TextAlign.center,
      color: context.color.textBody,
      textSpan: TextSpan(
        children: [
          TextSpan(text: 'terms_prefix'.tr),
          TextSpan(
            text: 'terms_and_conditions'.tr,
            recognizer: termsRecognizer,
            style: linkStyle,
          ),
          TextSpan(text: 'and'.tr),
          TextSpan(
            text: 'privacy_policy'.tr,
            recognizer: privacyRecognizer,
            style: linkStyle,
          ),
        ],
      ),
    );
  }
}
