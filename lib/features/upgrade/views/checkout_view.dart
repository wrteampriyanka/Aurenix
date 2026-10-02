import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_background.dart';
import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/app_fading_card.dart';
import '../../../commons/widgets/app_text_field.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/checkout_controller.dart';
import '../models/upgrade_plan.dart';
import '../widgets/upgrade_widgets.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
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
                      const SizedBox(height: 20),
                      _SectionLabel('upgrade_payment_address'.tr),
                      _AddressFields(controller: controller),
                      const SizedBox(height: 20),
                      _SectionLabel('upgrade_payment_method'.tr),
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
          CustomText(
            plan.nameKey.tr,
            maxLines: 1,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.color.textNatural,
          ),
          const SizedBox(height: 6),
          CustomText(
            plan.checkoutNoteKey.tr,
            fontSize: 13,
            color: context.color.textBody,
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: context.color.profileCardDivider,
          ),
          const SizedBox(height: 16),
          PlanPriceRow(
            plan: plan,
            action: AppButton(
              label: 'upgrade_change_plan'.tr,
              icon: null,
              onPressed: controller.onChangePlan,
              height: 42,
              width: 136,
              fontSize: 14,
              color: context.color.upgradeButton,
              highlightColor: context.color.upgradeButtonHighlight,
              borderColor: context.color.upgradeButtonBorder,
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
      child: CustomText(
        text,
        maxLines: 1,
        fontSize: 13,
        color: context.color.textBody,
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
            leading: Text(country.flag, style: const TextStyle(fontSize: 20)),
            onTap: controller.onCountryTap,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: states == null
                    ? AppTextField(
                        // A new field per country, so errors don't carry over.
                        key: ValueKey('state-${country.code}'),
                        hint: 'upgrade_state'.tr,
                        controller: controller.stateController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.addressState],
                        validator: controller.validateState,
                      )
                    : _PickerField(
                        key: ValueKey('state-${country.code}'),
                        value: controller.state.value,
                        hint: 'upgrade_select_state'.tr,
                        onTap: controller.onStateTap,
                        validator: () =>
                            controller.validateState(controller.state.value),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  key: ValueKey('postal-${country.code}'),
                  hint:
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
    final color = context.color;
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
          isEmpty: false,
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
                const SizedBox(width: 12),
              ],
              Expanded(
                child: CustomText(
                  value ?? hint ?? '',
                  maxLines: 1,
                  fontSize: 16,
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
    final color = context.color;
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
                child: CustomText(
                  method.labelKey.tr,
                  maxLines: 1,
                  fontSize: 15,
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
    final color = context.color;
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
        color: context.color.backgroundBase,
        border: Border(top: BorderSide(color: context.color.strokeDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  plan.dueToday,
                  maxLines: 1,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.color.textNatural,
                ),
                const SizedBox(height: 2),
                CustomText(
                  plan.autoChargeKey.tr,
                  maxLines: 2,
                  fontSize: 12,
                  color: context.color.textBody,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => AppButton(
              label: 'upgrade_pay_now'.tr,
              icon: null,
              onPressed: controller.isPaying.value ? null : controller.onPayNow,
              height: 46,
              width: 150,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
