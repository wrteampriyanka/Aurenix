import 'package:flutter/animation.dart';
import 'package:get/get.dart';

import '../../features/budget/bindings/budget_binding.dart';
import '../../features/budget/views/budget_view.dart';
import '../../features/categories/bindings/categories_binding.dart';
import '../../features/categories/views/categories_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/login/views/login_view.dart';
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

  static final routes = <GetPage>[
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
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
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
