import '../../../core/constants/app_assets.dart';

/// A paid plan offered on the upgrade screen. All texts are translation keys.
class UpgradePlan {
  const UpgradePlan({
    required this.id,
    required this.nameKey,
    required this.featureKeys,
    required this.priceKey,
    required this.renewalKey,
    required this.checkoutNoteKey,
    required this.autoChargeKey,
    required this.dueToday,
  });

  final String id;

  /// Plan name, e.g. "Aurenix Lite".
  final String nameKey;
  final List<String> featureKeys;

  /// Price shown while on the trial, e.g. "Free".
  final String priceKey;

  /// What the plan costs once the trial ends, e.g. "$149 after 3 months".
  final String renewalKey;

  /// Line under the plan name on the checkout screen.
  final String checkoutNoteKey;

  /// Line under the amount due at checkout.
  final String autoChargeKey;

  /// Charged now to verify the payment method, e.g. "$1.00".
  final String dueToday;

  static const lite = UpgradePlan(
    id: 'lite',
    nameKey: 'upgrade_lite_name',
    featureKeys: [
      'upgrade_feature_unlimited_prompts',
      'upgrade_feature_code_60',
      'upgrade_feature_images_8',
      'upgrade_feature_web_search_8h',
    ],
    priceKey: 'upgrade_price_free',
    renewalKey: 'upgrade_lite_renewal',
    checkoutNoteKey: 'upgrade_lite_checkout_note',
    autoChargeKey: 'upgrade_lite_auto_charge',
    dueToday: r'$1.00',
  );

  static const pro = UpgradePlan(
    id: 'pro',
    nameKey: 'upgrade_pro_name',
    featureKeys: [
      'upgrade_feature_unlimited_prompts',
      'upgrade_feature_code_unlimited',
      'upgrade_feature_images_15',
      'upgrade_feature_videos_5',
      'upgrade_feature_web_search_8h',
    ],
    priceKey: 'upgrade_price_free',
    renewalKey: 'upgrade_pro_renewal',
    checkoutNoteKey: 'upgrade_pro_checkout_note',
    autoChargeKey: 'upgrade_pro_auto_charge',
    dueToday: r'$1.00',
  );

  static const all = [lite, pro];
}

/// Ways to pay on the checkout screen.
enum PaymentMethod {
  playPurchase('upgrade_pay_play', AppAssets.playPurchaseLogo),
  razorpay('upgrade_pay_razorpay', AppAssets.razorpayLogo),
  phonepe('upgrade_pay_phonepe', AppAssets.phonepeLogo),
  paytm('upgrade_pay_paytm', AppAssets.paytmLogo);

  const PaymentMethod(this.labelKey, this.logo);

  final String labelKey;

  /// SVG or PNG asset path.
  final String logo;
}
