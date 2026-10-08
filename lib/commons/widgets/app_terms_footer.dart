import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/constants/app_strings.dart';

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
      color: appColors.textNatural,
      decoration: TextDecoration.underline,
      decorationColor: appColors.textNatural,
    );

    return AppText.rich(
      TextSpan(
        children: [
          TextSpan(text: AppStrings.termsPrefix.tr),
          TextSpan(
            text: AppStrings.termsAndConditions.tr,
            recognizer: termsRecognizer,
            style: linkStyle,
          ),
          TextSpan(text: AppStrings.and.tr),
          TextSpan(
            text: AppStrings.privacyPolicy.tr,
            recognizer: privacyRecognizer,
            style: linkStyle,
          ),
        ],
      ),
      fontSize: AppFontSize.overline,
      textAlign: TextAlign.center,
      color: appColors.textBody,
    );
  }
}
