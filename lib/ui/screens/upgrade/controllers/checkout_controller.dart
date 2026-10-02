import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ui/screens/widgets/app_picker_sheet.dart';
import '../models/country.dart';
import '../models/upgrade_plan.dart';

class CheckoutController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();

  /// State typed in for countries without a list in [Country.states].
  final stateController = TextEditingController();

  late final UpgradePlan plan;
  // TODO: preselect from the user's locale or saved billing address.
  final country = Country.india.obs;
  final state = RxnString();
  final paymentMethod = PaymentMethod.playPurchase.obs;
  final isPaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    plan = args is UpgradePlan ? args : UpgradePlan.lite;
  }

  Future<void> onCountryTap() async {
    final picked = await AppPickerSheet.show<Country>(
      title: 'upgrade_select_country'.tr,
      searchHint: 'upgrade_search_country'.tr,
      items: Country.all,
      labelOf: (c) => c.name,
      leadingOf: (c) => Text(c.flag, style: const TextStyle(fontSize: 22)),
      selected: country.value,
    );
    if (picked == null || picked == country.value) return;
    country.value = picked;
    // The old state and postal code belong to the old country.
    state.value = null;
    stateController.clear();
    pinController.clear();
  }

  Future<void> onStateTap() async {
    final states = country.value.states;
    if (states == null) return;
    final picked = await AppPickerSheet.show<String>(
      title: 'upgrade_select_state'.tr,
      searchHint: 'upgrade_search_state'.tr,
      items: states,
      labelOf: (s) => s,
      selected: state.value,
    );
    if (picked != null) state.value = picked;
  }

  void onPaymentMethod(PaymentMethod method) => paymentMethod.value = method;

  /// Back to the plan list.
  void onChangePlan() => Get.back();

  /// India uses a PIN code, everywhere else a postal or ZIP code.
  bool get usesPin => country.value == Country.india;

  String? validateState(String? value) =>
      (value?.trim() ?? '').isEmpty ? 'upgrade_state_required'.tr : null;

  String? validatePin(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return (usesPin ? 'upgrade_pin_required' : 'upgrade_postal_required').tr;
    }
    final valid = switch (country.value.code) {
      'IN' => RegExp(r'^[1-9]\d{5}$').hasMatch(code),
      'US' => RegExp(r'^\d{5}(-\d{4})?$').hasMatch(code),
      _ => RegExp(r'^[A-Za-z0-9][A-Za-z0-9 -]{1,9}$').hasMatch(code),
    };
    if (valid) return null;
    return (usesPin ? 'upgrade_pin_invalid' : 'upgrade_postal_invalid').tr;
  }

  Future<void> onPayNow() async {
    if (isPaying.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isPaying.value = true;
    try {
      // TODO: start the purchase with [paymentMethod] for [plan].
      await Future<void>.delayed(const Duration(milliseconds: 600));
      Get.snackbar(
        'upgrade_payment_title'.tr,
        'upgrade_payment_pending'.trParams({
          'method': paymentMethod.value.labelKey.tr,
        }),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPaying.value = false;
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    stateController.dispose();
    super.onClose();
  }
}
