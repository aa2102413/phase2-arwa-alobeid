import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/FB_Providers/cheque_provider.dart';
import 'package:yalapay/models/cheque.dart';
import '../FB_Repositories/payment_repo.dart';
import '../models/payment.dart';
class PaymentNotifier extends StateNotifier<List<Payment>> {
  PaymentNotifier() : super(const []);
  late final PaymentRepo _paymentRepo;

  

  Future<List<Payment>> build() async {
   await  _paymentRepo.initBanks();  _paymentRepo.initBanks(); 
    initalizeState();
    return [];
  }

  void initalizeState() async {
    _paymentRepo.observePayments().listen((payments) {
      state =payments;
    }).onError((error) {
      print(error);
    });

    //state = (await _paymentRepo.initPayments()).reversed.toList();
  }

void searchPayments(String text) async {
  final cheques = chequeNotifierProvider;
  final payments = await _paymentRepo.searchPayments(text, cheques as List<Cheque>);
  state = List.from(payments.reversed);
}

void addPayment(Payment payment) {
   _paymentRepo.addPayment(payment);
  state = List.from( _paymentRepo.payments.reversed); }


void deletePayment(Payment payment) async{
  await  _paymentRepo.deletePayment(payment);
  state = List.from(_paymentRepo.payments.reversed);
  }

  void updatePayment(Payment payment) async{
  await _paymentRepo.updatePayment(payment);
  state = List.from(_paymentRepo.payments.reversed);
  }

  Future<List<Payment>> paymentState(int id) {
    return _paymentRepo.getPaymentsByInvoiceNo(id);
  }

  int getlastId() {
    return _paymentRepo.payments.last.id;
  }

  List<String> getBanks() {
    return _paymentRepo.banks;
  }

  void resetState() {
    state = List.from(_paymentRepo.payments.reversed);
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