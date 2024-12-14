// ignore_for_file: unnecessary_null_comparison, recursive_getters

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/cheque.dart';
import '../models/payment.dart';

class PaymentRepo {
 
 late  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late  final CollectionReference paymentRef;
PaymentRepo(){
   paymentRef = _db.collection('payments');
}
   

List<String> _banks = [];
List<Payment> get payments => payments;
set payments(List<Payment> payments) => payments = payments;

  Stream<List<Payment>> observePayments() {
    return paymentRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  
  Future<List<Payment>> initPayments() async {
     List<Payment> payments = [];
     final snapshot = await paymentRef.get();
    if(snapshot.docs.isEmpty){
      var paymentData = await rootBundle.loadString('assets/data/payments.json');
      var paymentsMap = jsonDecode(paymentData);
       payments = paymentsMap.map<Payment>((payment) => Payment.fromJson(payment)).toList();
      
    final batch = _db.batch();
      for (var payment in payments) {
    var docRef = paymentRef.doc(payment.id.toString());
     batch.set(docRef, payment.toJson());}
    await batch.commit();

    }
    return payments;
  }


 Future<List<String>> initBanks() async {
    var bankData = await rootBundle.loadString('assets/data/banks.json');
    var banksMap = jsonDecode(bankData);

    _banks = banksMap.cast<String>();
    return _banks;
  }

  get banks => _banks;


 Future<Payment> getPaymentById(int id) async {
    final snapshot = await paymentRef.doc(id.toString()).get();
    return Payment.fromJson(snapshot.data() as Map<String, dynamic>);
  }


 Future<List<Payment>> getPaymentsByInvoiceNo(int invoiceNo)async{
    final queryResult =
        await paymentRef.where('invoiceNo', isEqualTo: invoiceNo).get();
    List<Payment> payments = queryResult.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Payment.fromJson(data);
    }).toList();

    return payments;
  }


  Future<List<Payment>> searchPayments(String text, List<Cheque> cheques)async {
    final isInteger = int.tryParse(text) != null;
    final querySnapshot = await paymentRef.get();
    final payments = querySnapshot.docs.map((doc) =>Payment.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
 
    return payments.where((payment) {
    bool matchesId = isInteger && payment.id == int.parse(text);

    bool matchesContent = payment.containsText(text.toLowerCase());

    bool matchesChequeStatus = false;

    bool matchChequeDetails = false;

    if (payment.chequeNo > 0) {
      Cheque? cheque = cheques.firstWhere(
        (cheque) => cheque.chequeNo == payment.chequeNo );
      if (cheque != null) {
        matchesChequeStatus = cheque.status.toLowerCase().contains(text.toLowerCase());
      }
    }

    if (payment.paymentMode.toLowerCase() == 'cheque') {
      Cheque? cheque = cheques.firstWhere((cheque) => cheque.chequeNo == payment.chequeNo);
      if (cheque != null) {
        matchChequeDetails = cheque.containsText(text.toLowerCase());
      }
    }

    return matchesId || matchesContent || matchesChequeStatus || matchChequeDetails;
  }).toList();
  }
 

  Future<void> addPayment(Payment payment) async {
    await paymentRef.add(payment.toJson());
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


  // Future<List<Payment>> getPaymentsByInvoiceNo(int invoiceNo)async {
  //   try{
  //     final snapshot = await paymentRef.where('invoiceNo', isEqualTo: invoiceNo).get();
  //     return snapshot.docs
  //         .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
  //         .toList();



  //   }catch(e){
  //      print('Error fetching payments: $e');
  //      return [];
  //   }
    
  // }

