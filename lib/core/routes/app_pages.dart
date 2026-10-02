import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/archive_chats/bindings/archive_chats_binding.dart';
import '../../features/archive_chats/views/archive_chats_view.dart';
import '../../features/budget/bindings/budget_binding.dart';
import '../../features/budget/views/budget_view.dart';
import '../../features/categories/bindings/categories_binding.dart';
import '../../features/categories/views/categories_view.dart';
import '../../features/connected_apps/bindings/connected_apps_binding.dart';
import '../../features/connected_apps/views/connected_apps_view.dart';
import '../../features/customize_ai/bindings/customize_ai_binding.dart';
import '../../features/customize_ai/views/customize_ai_view.dart';
import '../../features/data_control/bindings/data_control_binding.dart';
import '../../features/data_control/views/data_control_view.dart';
import '../../features/edit_profile/bindings/edit_profile_binding.dart';
import '../../features/edit_profile/views/edit_profile_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/legal/views/legal_view.dart';
import '../../features/live_talk/bindings/live_talk_binding.dart';
import '../../features/live_talk/views/live_talk_view.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/login/views/login_view.dart';
import '../../features/memories/bindings/memories_binding.dart';
import '../../features/memories/views/memories_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/otp/bindings/otp_binding.dart';
import '../../features/otp/views/otp_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/register/bindings/register_binding.dart';
import '../../features/register/views/register_view.dart';
import '../../features/reset_password/bindings/reset_password_binding.dart';
import '../../features/reset_password/views/reset_password_view.dart';
import '../../features/savings/bindings/savings_binding.dart';
import '../../features/savings/views/savings_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/transactions/bindings/transactions_binding.dart';
import '../../features/transactions/views/transactions_view.dart';
import '../../features/voice_settings/bindings/voice_settings_binding.dart';
import '../../features/voice_settings/views/voice_settings_view.dart';
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

  static final routes = <GetPage>[
    _screen(AppRoutes.aboutUs, () => const LegalView(page: LegalPage.aboutUs)),
    _screen(
      AppRoutes.archiveChats,
      () => const ArchiveChatsView(),
      ArchiveChatsBinding(),
    ),
    _screen(AppRoutes.budget, () => const BudgetView(), BudgetBinding()),
    _screen(
      AppRoutes.categories,
      () => const CategoriesView(),
      CategoriesBinding(),
    ),
    _screen(
      AppRoutes.connectedApps,
      () => const ConnectedAppsView(),
      ConnectedAppsBinding(),
    ),
    _screen(
      AppRoutes.customizeAi,
      () => const CustomizeAiView(),
      CustomizeAiBinding(),
    ),
    _screen(
      AppRoutes.dataControl,
      () => const DataControlView(),
      DataControlBinding(),
    ),
    _screen(
      AppRoutes.editProfile,
      () => const EditProfileView(),
      EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      customTransition: _StayBelowTransition(),
    ),
    GetPage(
      name: AppRoutes.liveTalk,
      page: () => const LiveTalkView(),
      binding: LiveTalkBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    _screen(AppRoutes.memories, () => const MemoriesView(), MemoriesBinding()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    _screen(
      AppRoutes.privacyPolicy,
      () => const LegalView(page: LegalPage.privacyPolicy),
    ),
    _screen(AppRoutes.profile, () => const ProfileView(), ProfileBinding()),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
      transition: _authTransition,
      transitionDuration: _authTransitionDuration,
      curve: _authTransitionCurve,
    ),
    _screen(AppRoutes.savings, () => const SavingsView(), SavingsBinding()),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    _screen(
      AppRoutes.transactions,
      () => const TransactionsView(),
      TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.voiceSettings,
      page: () => const VoiceSettingsView(),
      binding: VoiceSettingsBinding(),
      transition: Transition.downToUp,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
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
