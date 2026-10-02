import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/archive_chats/bindings/archive_chats_binding.dart';
import '../../ui/screens/archive_chats/archive_chats_screen.dart';
import '../../features/budget/bindings/budget_binding.dart';
import '../../ui/screens/budget/budget_screen.dart';
import '../../features/categories/bindings/categories_binding.dart';
import '../../ui/screens/categories/categories_screen.dart';
import '../../features/connected_apps/bindings/connected_apps_binding.dart';
import '../../ui/screens/connected_apps/connected_apps_screen.dart';
import '../../features/customize_ai/bindings/customize_ai_binding.dart';
import '../../ui/screens/customize_ai/customize_ai_screen.dart';
import '../../features/data_control/bindings/data_control_binding.dart';
import '../../ui/screens/data_control/data_control_screen.dart';
import '../../features/edit_profile/bindings/edit_profile_binding.dart';
import '../../ui/screens/edit_profile/edit_profile_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/legal/legal_screen.dart';
import '../../features/live_talk/bindings/live_talk_binding.dart';
import '../../ui/screens/live_talk/live_talk_screen.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../ui/screens/login/login_screen.dart';
import '../../features/memories/bindings/memories_binding.dart';
import '../../ui/screens/memories/memories_screen.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../ui/screens/onboarding/onboarding_screen.dart';
import '../../features/otp/bindings/otp_binding.dart';
import '../../ui/screens/otp/otp_screen.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../features/projects/bindings/projects_binding.dart';
import '../../ui/screens/projects/projects_screen.dart';
import '../../features/register/bindings/register_binding.dart';
import '../../ui/screens/register/register_screen.dart';
import '../../features/reset_password/bindings/reset_password_binding.dart';
import '../../ui/screens/reset_password/reset_password_screen.dart';
import '../../features/savings/bindings/savings_binding.dart';
import '../../ui/screens/savings/savings_screen.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../ui/screens/splash/splash_screen.dart';
import '../../features/transactions/bindings/transactions_binding.dart';
import '../../ui/screens/transactions/transactions_screen.dart';
import '../../features/upgrade/bindings/checkout_binding.dart';
import '../../features/upgrade/bindings/upgrade_binding.dart';
import '../../ui/screens/upgrade/checkout_screen.dart';
import '../../ui/screens/upgrade/upgrade_screen.dart';
import '../../features/voice_settings/bindings/voice_settings_binding.dart';
import '../../ui/screens/voice_settings/voice_settings_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  // Login, register and OTP share the same background, so a cross-fade makes
  // switching between them look like only the form is changing.
  static const _authTransition = Transition.fadeIn;
  static const _authTransitionDuration = Duration(milliseconds: 450);
  static const _authTransitionCurve = Curves.easeInOut;

  // Screens slide in over the one below, which drifts left and dims, instead
  // of the platform zoom, which flashes a dark fill between the two screens.
  static final _screenTransition = _SlideParallaxTransition();
  static const _screenTransitionDuration = Duration(milliseconds: 420);
  static const _screenTransitionCurve = Curves.fastEaseInToSlowEaseOut;

  /// A screen that uses [_screenTransition] and can be swiped back from the
  /// left edge.
  static GetPage _screen(
    String name,
    GetPageBuilder page, [
    Bindings? binding,
  ]) => GetPage(
    name: name,
    page: page,
    binding: binding,
    customTransition: _screenTransition,
    transitionDuration: _screenTransitionDuration,
    curve: _screenTransitionCurve,
    popGesture: true,
  );

  // Full-screen sheets (closed with a ✕) rise from the bottom over the
  // screen below, which stays put.
  static final _sheetTransition = _SheetUpTransition();
  static const _sheetTransitionDuration = Duration(milliseconds: 380);

  /// A screen that uses [_sheetTransition]. It has no swipe back, since a
  /// sideways swipe doesn't match a page that came up from the bottom.
  static GetPage _sheet(
    String name,
    GetPageBuilder page, [
    Bindings? binding,
  ]) => GetPage(
    name: name,
    page: page,
    binding: binding,
    customTransition: _sheetTransition,
    transitionDuration: _sheetTransitionDuration,
    curve: Curves.easeOutCubic,
    popGesture: false,
  );

  static final routes = <GetPage>[
    _screen(AppRoutes.aboutUs, () => const LegalScreen(page: LegalPage.aboutUs)),
    _screen(
      AppRoutes.archiveChats,
      () => const ArchiveChatsScreen(),
      ArchiveChatsBinding(),
    ),
    _screen(AppRoutes.budget, () => const BudgetScreen(), BudgetBinding()),
    _screen(
      AppRoutes.categories,
      () => const CategoriesScreen(),
      CategoriesBinding(),
    ),
    _screen(AppRoutes.checkout, () => const CheckoutScreen(), CheckoutBinding()),
    _screen(
      AppRoutes.connectedApps,
      () => const ConnectedAppsScreen(),
      ConnectedAppsBinding(),
    ),
    _screen(
      AppRoutes.customizeAi,
      () => const CustomizeAiScreen(),
      CustomizeAiBinding(),
    ),
    _screen(
      AppRoutes.dataControl,
      () => const DataControlScreen(),
      DataControlBinding(),
    ),
    _screen(
      AppRoutes.editProfile,
      () => const EditProfileScreen(),
      EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      customTransition: _StayBelowTransition(),
    ),
    GetPage(
      name: AppRoutes.liveTalk,
      page: () => const LiveTalkScreen(),
      binding: LiveTalkBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    _screen(AppRoutes.memories, () => const MemoriesScreen(), MemoriesBinding()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    _screen(
      AppRoutes.privacyPolicy,
      () => const LegalScreen(page: LegalPage.privacyPolicy),
    ),
    _screen(AppRoutes.profile, () => const ProfileScreen(), ProfileBinding()),
    _screen(AppRoutes.projects, () => const ProjectsScreen(), ProjectsBinding()),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    _screen(AppRoutes.savings, () => const SavingsScreen(), SavingsBinding()),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    _screen(
      AppRoutes.transactions,
      () => const TransactionsScreen(),
      TransactionsBinding(),
    ),
    _sheet(AppRoutes.upgrade, () => const UpgradeScreen(), UpgradeBinding()),
    _sheet(
      AppRoutes.voiceSettings,
      () => const VoiceSettingsScreen(),
      VoiceSettingsBinding(),
    ),
  ];
}

/// Slides the page in from the right edge. While another page covers it,
/// the page drifts a little to the left and dims, so the two move together.
///
/// Popping plays the same curve mirrored, so the page leaves quickly and
/// settles gently, and a back swipe tracks the finger with no curve.
class _SlideParallaxTransition extends CustomTransition {
  static final _enter = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  );
  static final _behind = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.3, 0),
  );
  static final _dim = Tween<double>(begin: 0, end: 0.35);

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final route = ModalRoute.of(context);
    final dragging = route is GetPageRoute && route.popGestureInProgress;
    final c = curve ?? Curves.fastEaseInToSlowEaseOut;

    final primary = dragging
        ? animation
        : CurvedAnimation(parent: animation, curve: c, reverseCurve: c.flipped);
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: c,
      reverseCurve: c.flipped,
    );

    return SlideTransition(
      position: _behind.animate(secondary),
      child: SlideTransition(
        position: _enter.animate(primary),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _dim.animate(secondary),
                  child: const ColoredBox(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slides the page up from the bottom edge with an ease-out, and back down
/// with the mirrored curve. The page is isolated in a [RepaintBoundary] so
/// moving it only re-composites it instead of repainting its contents.
///
/// GetX's [Transition.downToUp] ignores the route curve, so it moves at a
/// flat linear speed, which reads as stiff.
class _SheetUpTransition extends CustomTransition {
  static final _enter = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final c = curve ?? Curves.easeOutCubic;
    return SlideTransition(
      position: _enter.animate(
        CurvedAnimation(parent: animation, curve: c, reverseCurve: c.flipped),
      ),
      child: RepaintBoundary(child: child),
    );
  }
}

/// The platform transition for entering the page, but the page stays put
/// when another route is pushed over it. The default Android transition
/// fades it out to black instead, so a fading page on top flashes dark.
class _StayBelowTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Theme.of(context).pageTransitionsTheme.buildTransitions(
      ModalRoute.of(context) as PageRoute,
      context,
      animation,
      kAlwaysDismissedAnimation,
      child,
    );
  }
}
