import 'package:get/get.dart';

import 'package:aurenix/features/transactions/controllers/transactions_controller.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}
