import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/firestore_repo/payments_repo.dart';
import 'package:quickmart/models/payment.dart';

import '../fb_repo_provider.dart/payment_repo_provider.dart';

class PaymentNotifier extends AsyncNotifier<List<Payment>> {
  late final PaymentRepo _paymentRepo;

  @override
  Future<List<Payment>> build() async {
    _paymentRepo = await ref.watch(paymentRepoProvider.future);

    // Listen to the stream and emit the data
    _paymentRepo.observePayments().listen((payments) {
      state = AsyncValue.data(payments);
    }).onError((error) {
      print(error);
    });
   return []; }


  //-----------

  void addPayment(Payment payment) async {
    await _paymentRepo.addPayment(payment);}

  //-----------

  void updatePayment(Payment payment) async {
    try {
      await _paymentRepo.updatePayment(payment);
    } catch (e) {
      print(e); } }

  //-----------

  void deleteProject(Payment payment) async {
    await _paymentRepo.deletePayment(payment);}
 
  //-----------

  Future<List<Payment>> loadPayments(String invoiceNo) async {
    return await _paymentRepo.loadPayments(invoiceNo);
  }
  
  //-----------

}

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, List<Payment>>(
        () => PaymentNotifier());
