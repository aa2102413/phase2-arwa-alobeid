import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/cheque.dart';
import '../models/payment.dart';

class PaymentRepo {
  final CollectionReference paymentRef;
 PaymentRepo({required this.paymentRef});

  List<String> _banks = [];

  Stream<List<Payment>> observePayments() {
    return paymentRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

 Future<List<String>> initBanks() async {
    var bankData = await rootBundle.loadString('assets/data/banks.json');
    var banksMap = jsonDecode(bankData);

    _banks = banksMap.cast<String>();
    return _banks;
  }

  get banks => _banks;


 Future<Payment> getPaymentById(int id) async {
    final snapshot = await paymentRef.doc(id as String?).get();
    return Payment.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  Future<List<Payment>> getPaymentsByInvoiceNo(int invoiceNo)async {
    return [];
  }

  Future<List<Payment>> searchPayments(String text, List<Cheque> cheques)async {
    return [];
  }

  Future<void> addPayment(Payment payment) async {
    var docId = paymentRef.doc().id;
    payment.id = docId as int;
    await paymentRef.doc(docId).set(payment.toJson());
  }


  Future<void> deletePayment(Payment payment) => paymentRef.doc(payment.id as String?).delete();

  Future<void> updatePayment(Payment payment) => paymentRef.doc(payment.id as String?).update(payment.toJson());



  Future<List<Payment>> loadPayments(String invoiceNo) async {
    final queryResult =
        await paymentRef.where('invoiceNo', isEqualTo: invoiceNo).get();
    List<Payment> payments = queryResult.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Payment.fromJson(data);
    }).toList();

    return payments;
  }

}
