import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/archive_chats/bindings/archive_chats_binding.dart';
import '../../features/archive_chats/views/archive_chats_view.dart';
import '../../features/budget/bindings/budget_binding.dart';
import '../../features/budget/views/budget_view.dart';
import '../../features/categories/bindings/categories_binding.dart';
import '../../features/categories/views/categories_view.dart';
import '../../features/customize_ai/bindings/customize_ai_binding.dart';
import '../../features/customize_ai/views/customize_ai_view.dart';
import '../../features/data_control/bindings/data_control_binding.dart';
import '../../features/data_control/views/data_control_view.dart';
import '../../features/edit_profile/bindings/edit_profile_binding.dart';
import '../../features/edit_profile/views/edit_profile_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
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
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  // Login, register and OTP share the same background, so a cross-fade makes
  // switching between them look like only the form is changing.
  static const _authTransition = Transition.fadeIn;
  static const _authTransitionDuration = Duration(milliseconds: 450);
  static const _authTransitionCurve = Curves.easeInOut;

  // Profile screens fade in while sliding a little from the right, instead of
  // the platform zoom, which flashes a dark fill between the two screens.
  static final _screenTransition = _FadeSlideTransition();
  static const _screenTransitionDuration = Duration(milliseconds: 380);
  static const _screenTransitionCurve = Curves.easeOutCubic;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.archiveChats,
      page: () => const ArchiveChatsView(),
      binding: ArchiveChatsBinding(),
      customTransition: _screenTransition,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.budget,
      page: () => const BudgetView(),
      binding: BudgetBinding(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.customizeAi,
      page: () => const CustomizeAiView(),
      binding: CustomizeAiBinding(),
      customTransition: _screenTransition,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.dataControl,
      page: () => const DataControlView(),
      binding: DataControlBinding(),
      customTransition: _screenTransition,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      customTransition: _screenTransition,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
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
    GetPage(
      name: AppRoutes.memories,
      page: () => const MemoriesView(),
      binding: MemoriesBinding(),
      customTransition: _screenTransition,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
    ),
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
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      customTransition: _screenTransition,
      transitionDuration: _screenTransitionDuration,
      curve: _screenTransitionCurve,
    ),
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
    GetPage(
      name: AppRoutes.savings,
      page: () => const SavingsView(),
      binding: SavingsBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
  ];
}

/// Fades the page in while it slides a short way in from the right.
class _FadeSlideTransition extends CustomTransition {
  static final _offset = Tween<Offset>(
    begin: const Offset(0.08, 0),
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
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: _offset.animate(curved), child: child),
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
