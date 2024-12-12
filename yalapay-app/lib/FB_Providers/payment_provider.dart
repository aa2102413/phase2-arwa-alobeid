import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../FB_Repo_provider/payment_repo_provider.dart';
import '../FB_Repositories/payment_repo.dart';
import '../models/payment.dart';
class PaymentNotifier extends AsyncNotifier<List<Payment>> {
  late final PaymentRepo _paymentRepo;

  @override
  Future<List<Payment>> build() async {
    _paymentRepo = await ref.watch(paymentRepoProvider.future);
    _paymentRepo.observePayments().listen((payments) {
      state = AsyncValue.data(payments);
    }).onError((error) {
      print(error);
    });
   return []; }




}

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, List<Payment>>(
        () => PaymentNotifier());