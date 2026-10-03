import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/app_plain_background.dart';
import 'package:aurenix/core/theme/app_colors.dart';

/// A static text document reached from the profile menu. Its body is
/// markdown kept in the translations.
enum LegalPage {
  privacyPolicy('profile_privacy_policy', 'privacy_policy_body'),
  aboutUs('profile_about_us', 'about_us_body');

  const LegalPage(this.titleKey, this.bodyKey);

  final String titleKey;
  final String bodyKey;
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.page});

  final LegalPage page;

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(
      color: context.color.textBody,
      fontSize: 14,
      height: 1.45,
    );
    return AppDetailPage(
      title: page.titleKey.tr,
      child: MarkdownBody(
        data: page.bodyKey.tr,
        styleSheet: MarkdownStyleSheet(
          p: body,
          listBullet: body,
          listIndent: 28,
          blockSpacing: 16,
          strong: body.copyWith(fontWeight: FontWeight.w600),
          h3: body.copyWith(
            color: context.color.textNatural,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          h3Padding: const EdgeInsets.only(top: 8),
        ),
      ),
    );
  }
}
