import 'package:get/get.dart';

import '../../features/budget/bindings/budget_binding.dart';
import '../../features/budget/views/budget_view.dart';
import '../../features/categories/bindings/categories_binding.dart';
import '../../features/categories/views/categories_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/login/views/login_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/savings/bindings/savings_binding.dart';
import '../../features/savings/views/savings_view.dart';
import '../../features/transactions/bindings/transactions_binding.dart';
import '../../features/transactions/views/transactions_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

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
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.savings,
      page: () => const SavingsView(),
      binding: SavingsBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
  ];
}
