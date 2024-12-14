import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/FB_Providers/cheque_provider.dart';
import 'package:yalapay/models/cheque.dart';
import '../FB_Repositories/payment_repo.dart';
import '../models/payment.dart';

class PaymentNotifier extends StateNotifier<List<Payment>> {
  PaymentNotifier() : super(const []){
 initalizeState();
  }
  late final PaymentRepo _paymentRepo;

  void initalizeState() async {
  //  _paymentRepo.observePayments();
    _paymentRepo.observePayments().listen((payments) {
      state = payments;
    }).onError((error) {
       print("Error observing payments: $error");
    });
    //state = (await _paymentRepo.initPayments()).reversed.toList();
  }

  void searchPayments(String text) async {
    final cheques = chequeNotifierProvider;
    final payments =
        await _paymentRepo.searchPayments(text, cheques as List<Cheque>);
    state = payments.reversed.toList();
  }

  void addPayment(Payment payment) {
    _paymentRepo.addPayment(payment);
    state = _paymentRepo.payments.reversed.toList();
  }

  void deletePayment(Payment payment) async {
    await _paymentRepo.deletePayment(payment);
  state = _paymentRepo.payments.reversed.toList();
  }

  void updatePayment(Payment payment) async {
    await _paymentRepo.updatePayment(payment);
   state = _paymentRepo.payments.reversed.toList();
  }

  void resetState() {
      state = _paymentRepo.payments.reversed.toList();
  }
}

final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, List<Payment>>(
        (ref) => PaymentNotifier());


       // @override
  // Future<List<Payment>> build() async {
  //   _paymentRepo = await ref.watch(paymentRepoProvider.future);
  //   _paymentRepo.observePayments().listen((payments) {
  //     state = AsyncValue.data(payments);
  //   }).onError((error) {
  //     print(error);
  //   });
  //  return []; }