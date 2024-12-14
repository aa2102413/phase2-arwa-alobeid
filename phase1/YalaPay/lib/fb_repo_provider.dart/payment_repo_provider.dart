import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/firestore_repo/payments_repo.dart';

final paymentRepoProvider = FutureProvider<PaymentRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  return PaymentRepo(
    paymentRef: db.collection('payments'),
     invoiceRef: db.collection('invoices')
  );
});
 final selectedPaymentIdProvider = StateProvider<String?>((ref) => null);