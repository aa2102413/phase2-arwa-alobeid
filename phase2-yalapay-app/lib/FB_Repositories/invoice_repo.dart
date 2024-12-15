import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/cheque.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class InvoiceRepo {
  late final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference invoiceRef;
  InvoiceRepo() {
    invoiceRef = _db.collection('invoices');
  }

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;
  set invoices(List<Invoice> invoices) => _invoices = invoices;

  Stream<List<Invoice>> observeInvoices() {
    return invoiceRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Invoice.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Invoice>> initInvoices() async {
    List<Invoice> invoices = [];
    final snapshot = await invoiceRef.get();
    if (snapshot.docs.isEmpty) {
      var paymentData =
          await rootBundle.loadString('assets/data/invoices.json');
      var paymentsMap = jsonDecode(paymentData);
      invoices = paymentsMap
          .map<Payment>((payment) => Invoice.fromJson(payment))
          .toList();
      final batch = _db.batch();
      for (var invoice in invoices) {
        var docRef = invoiceRef.doc(invoice.id.toString());
        batch.set(docRef, invoice.toJson());
      }
      await batch.commit();
    }
    return invoices;
  }

  Future<Invoice> getInvoiceById(int id) =>
      invoiceRef.doc(id as String?).get().then((snapshot) {
        return Invoice.fromJson(snapshot.data() as Map<String, dynamic>);
      });

  Future<void> addInvoice(Invoice invoice) async {
    await invoiceRef.add(invoice.toJson());
  }

  Future<void> deleteInvoice(Invoice invoice) async {
    var snapshot = await invoiceRef.where('id', isEqualTo: invoice.id).get();
    if (snapshot.docs.isNotEmpty) {
      await invoiceRef.doc(snapshot.docs.first.id).delete();
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    var snapshot = await invoiceRef.where('id', isEqualTo: invoice.id).get();
    if (snapshot.docs.isNotEmpty) {
      await invoiceRef.doc(snapshot.docs.first.id).update(invoice.toJson());
    }
  }

  Future<List<Invoice>> getByInvoiceDate(
      DateTime fromDate, DateTime toDate) async {
    final queryResult = await invoiceRef
        .where('invoiceDate', isGreaterThan: fromDate)
        .where('dueDate', isLessThan: toDate)
        .get();

    List<Invoice> invoices = queryResult.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Invoice.fromJson(data);
    }).toList();

    return invoices;
  }

  Future<List<Invoice>> searchInvoices(
      String text, List<Payment> payments, List<Cheque> cheques) async {
    final isInteger = int.tryParse(text) != null;
    final invoiceQuerySnapshot = await invoiceRef.get();
    final invoices = invoiceQuerySnapshot.docs
        .map((doc) => Invoice.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return invoices.where((invoice) {
      double amountDue = invoice.amount;
      bool containsAwaitingPayments = false;

      for (var payment in payments) {
        if (invoice.id == payment.invoiceNo) {
          if (payment.chequeNo > 0) {
            Cheque cheque = cheques
                .firstWhere((cheque) => cheque.chequeNo == payment.chequeNo);

            if (cheque.status != 'Returned') {
              amountDue -= cheque.amount;
            }

            if (cheque.status == 'Deposited' || cheque.status == 'Awaiting') {
              containsAwaitingPayments = true;
            }
          } else {
            amountDue -= payment.amount;
          }
        }
      }

      bool matchesId = isInteger && invoice.id == int.parse(text);
      bool matchesDescription = invoice.containsText(text.toLowerCase());
      bool matchesStatus =
          ('due'.contains(text.toLowerCase()) && amountDue > 0) ||
              ('awaiting payments'.contains(text.toLowerCase()) &&
                  amountDue == 0 &&
                  containsAwaitingPayments) ||
              ('fully paid'.contains(text.toLowerCase()) &&
                  amountDue == 0 &&
                  !containsAwaitingPayments);

      return matchesId || matchesDescription || matchesStatus;
    }).toList();
  }
}
