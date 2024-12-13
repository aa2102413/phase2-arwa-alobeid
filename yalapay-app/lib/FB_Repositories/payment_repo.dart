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
      
       for (var payment in  payments) {
        await paymentRef.doc(payment.id.toString()).set(payment.toJson());
    }

    }else { // Load from Firestore
    payments = snapshot.docs.map((doc) =>Payment.fromJson(doc.data() as Map<String, dynamic>)).toList();
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
    final snapshot = await paymentRef.doc(id as String?).get();
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
    final payments = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Payment.fromJson(data);
    }).toList();

    return payments.where((payment) {
    bool matchesId = isInteger && payment.id == int.parse(text);

    bool matchesContent = payment.containsText(text.toLowerCase());

    bool matchesChequeStatus = false;

    bool matchChequeDetails = false;

    if (payment.chequeNo > 0) {
      Cheque? cheque = cheques.firstWhere(
        (cheque) => cheque.chequeNo == payment.chequeNo,
        orElse: () => null,
      );
      if (cheque != null) {
        matchesChequeStatus = cheque.status.toLowerCase().contains(text.toLowerCase());
      }
    }

    if (payment.paymentMode.toLowerCase() == 'cheque') {
      Cheque? cheque = cheques.firstWhere(
        (cheque) => cheque.chequeNo == payment.chequeNo,
        orElse: () => null,
      );
      if (cheque != null) {
        matchChequeDetails = cheque.containsText(text.toLowerCase());
      }
    }

    return matchesId || matchesContent || matchesChequeStatus || matchChequeDetails;
  }).toList();
  }
  /**List<Payment> searchPayments(String text, List<Cheque> cheques) {
    final isInteger = int.tryParse(text) != null;

    return payments.where((payment) {
      bool matchesId = isInteger && payment.id == int.parse(text);

      bool matchesContent = payment.containsText(text.toLowerCase());

      bool matchesChequeStatus = false;

      bool matchChequeDetails = false;

      if (payment.chequeNo > 0) {
        Cheque? cheque = cheques.firstWhere((cheque) => cheque.chequeNo == payment.chequeNo);
        matchesChequeStatus = cheque.status.toLowerCase().contains(text.toLowerCase());
      }

      if(payment.paymentMode.toLowerCase() == 'cheque'){
        Cheque? cheque = cheques.firstWhere((cheque) => cheque.chequeNo == payment.chequeNo);
        matchChequeDetails = cheque.containsText(text.toLowerCase());
      }

      return matchesId || matchesContent || matchesChequeStatus || matchChequeDetails;
    }).toList();
  } */

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
