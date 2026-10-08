import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_fading_card.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/upgrade/controllers/checkout_controller.dart';
import 'package:aurenix/features/upgrade/models/upgrade_plan.dart';
import 'package:aurenix/features/upgrade/widgets/upgrade_widgets.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
      body: AppBackground(
        showGrid: false,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UpgradeTopButton(
                icon: PhosphorIconsRegular.caretLeft,
                onTap: Get.back,
              ),
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      _PlanSummary(controller: controller),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionLabel(AppStrings.upgradePaymentAddress.tr),
                      _AddressFields(controller: controller),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionLabel(AppStrings.upgradePaymentMethod.tr),
                      for (final method in PaymentMethod.values) ...[
                        Obx(
                          () => _PaymentMethodTile(
                            method: method,
                            selected: controller.paymentMethod.value == method,
                            onTap: () => controller.onPaymentMethod(method),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              _PayBar(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final plan = controller.plan;
    return AppFadingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            plan.nameKey.tr,
            maxLines: 1,
            fontSize: AppFontSize.h2,
            fontWeight: FontWeight.w600,
            color: appColors.textNatural,
          ),
          const SizedBox(height: 6),
          AppText(
            plan.checkoutNoteKey.tr,
            fontSize: AppFontSize.caption,
            color: appColors.textBody,
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, thickness: 1, color: appColors.profileCardDivider),
          const SizedBox(height: AppSpacing.lg),
          PlanPriceRow(
            plan: plan,
            action: AppButton(
              label: AppStrings.upgradeChangePlan.tr,
              icon: null,
              onPressed: controller.onChangePlan,
              height: 42,
              width: 136,
              fontSize: AppFontSize.label,
              color: appColors.upgradeButton,
              highlightColor: appColors.upgradeButtonHighlight,
              borderColor: appColors.upgradeButtonBorder,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppText(
        text,
        maxLines: 1,
        fontSize: AppFontSize.caption,
        color: appColors.textBody,
      ),
    );
  }
}

/// Country, then state and PIN code side by side.
class _AddressFields extends StatelessWidget {
  const _AddressFields({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final country = controller.country.value;
      final states = country.states;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PickerField(
            value: country.name,
            // A flag glyph, not text: sized to the row, not to the type scale.
            leading: Text(country.flag, style: const TextStyle(fontSize: 20)),
            onTap: controller.onCountryTap,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: states == null
                    ? AppTextField(
                        // A new field per country, so errors don't carry over.
                        key: ValueKey('state-${country.code}'),
                        label: AppStrings.upgradeState.tr,
                        // Shares a Row with the postal code field.
                        reserveErrorSpace: true,
                        controller: controller.stateController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.addressState],
                        validator: controller.validateState,
                      )
                    : _PickerField(
                        key: ValueKey('state-${country.code}'),
                        value: controller.state.value,
                        hint: AppStrings.upgradeSelectState.tr,
                        onTap: controller.onStateTap,
                        validator: () =>
                            controller.validateState(controller.state.value),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  key: ValueKey('postal-${country.code}'),
                  reserveErrorSpace: true,
                  label:
                      (controller.usesPin
                              ? 'upgrade_pin_code'
                              : 'upgrade_postal_code')
                          .tr,
                  controller: controller.pinController,
                  keyboardType: controller.usesPin || country.code == 'US'
                      ? TextInputType.number
                      : TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.postalCode],
                  inputFormatters: [
                    if (controller.usesPin)
                      FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      controller.usesPin ? 6 : 10,
                    ),
                  ],
                  validator: controller.validatePin,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

/// Looks like [AppTextField] but opens a picker sheet when tapped.
class _PickerField extends StatelessWidget {
  const _PickerField({
    super.key,
    required this.value,
    required this.onTap,
    this.hint,
    this.leading,
    this.validator,
  });

  /// Shown in white; [hint] is shown in grey while this is null.
  final String? value;
  final Future<void> Function() onTap;
  final String? hint;
  final Widget? leading;

  /// Reads the current value itself, since it changes inside [onTap].
  final String? Function()? validator;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return FormField<String>(
      validator: validator == null ? null : (_) => validator!(),
      builder: (field) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await onTap();
          // Clear the error as soon as a value is picked.
          if (field.hasError) field.validate();
        },
        child: InputDecorator(
          decoration: AppTextField.decoration(context).copyWith(
            errorText: field.errorText,
            suffixIcon: Icon(
              PhosphorIconsRegular.caretDown,
              size: 20,
              color: color.textNatural,
            ),
          ),
          child: Row(
            children: [
              if (leading case final leading?) ...[
                leading,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: AppText(
                  value ?? hint ?? '',
                  maxLines: 1,
                  fontSize: AppFontSize.body,
                  color: value == null ? color.textBody : color.textNatural,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.inputFill,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color.primary : color.inputBorder,
            ),
          ),
          child: Row(
            children: [
              _PaymentLogo(asset: method.logo),
              const SizedBox(width: 14),
              Expanded(
                child: AppText(
                  method.labelKey.tr,
                  maxLines: 1,
                  fontSize: AppFontSize.chat,
                  color: color.textNatural,
                ),
              ),
              _RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({required this.asset});

  final String asset;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(asset, width: _size, height: _size);
    }
    return Image.asset(asset, width: _size, height: _size);
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color.primary : color.divider,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.primary,
          ),
        ),
      ),
    );
  }
}

/// Amount due now and the auto charge, with the Pay Now button.
class _PayBar extends StatelessWidget {
  const _PayBar({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final plan = controller.plan;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: appColors.backgroundBase,
        border: Border(top: BorderSide(color: appColors.strokeDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  plan.dueToday,
                  maxLines: 1,
                  fontSize: AppFontSize.h2,
                  fontWeight: FontWeight.w700,
                  color: appColors.textNatural,
                ),
                const SizedBox(height: 2),
                AppText(
                  plan.autoChargeKey.tr,
                  maxLines: 2,
                  fontSize: AppFontSize.overline,
                  color: appColors.textBody,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Obx(
            () => AppButton(
              label: AppStrings.upgradePayNow.tr,
              icon: null,
              onPressed: controller.isPaying.value ? null : controller.onPayNow,
              height: 46,
              width: 150,
              fontSize: AppFontSize.chat,
            ),
          ),
        ],
      ),
    );
  }
}
