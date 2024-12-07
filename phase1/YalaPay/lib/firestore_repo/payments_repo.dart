import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmart/models/invoice.dart';
import 'package:quickmart/models/payment.dart';

class PaymentRepo {
  final CollectionReference paymentRef;
   final CollectionReference invoiceRef;

  PaymentRepo({required this.paymentRef,required this.invoiceRef});

//invoices
Stream<List<Invoice>> observeInvoices() {
    return invoiceRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Invoice.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

Future<Invoice?> getInvoiceById(String id) =>
      invoiceRef.doc(id).get().then((snapshot) {
        return Invoice.fromJson(snapshot.data() as Map<String, dynamic>);
      });

 Future<void> addInvoice(Invoice invoice) async {
    var docId =
        invoiceRef.doc().id; //will create an empty document with a unique id
   invoice.id = docId;
    await invoiceRef.doc(docId).set(invoice.toJson()); //it will add a new document if the doc does not exit or update if it exists
  }

  Future<void> updateInvoice(Invoice invoice) =>
      invoiceRef.doc(invoice.id).update(invoice.toJson());

  Future<void> deleteInvoice(Invoice invoice) async {
    await invoiceRef.doc(invoice.id).delete();
    //delete all todos associated with the project
    await invoiceRef.where('pid', isEqualTo: invoice.id).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        // doc.reference.delete();
        invoiceRef.doc(doc.id).delete();
      }
    });
  }


//payments
  Stream<List<Payment>> observePayments() {
    return paymentRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }



  Future<Payment> getPaymentById(String id) async {
    final snapshot = await paymentRef.doc(id).get();
    return Payment.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  Future<void> addPayment(Payment payment) async {
    var docId = paymentRef.doc().id;
    payment.id = docId;
    await paymentRef.doc(docId).set(payment.toJson());
  }

  Future<void> updatePayment(Payment payment) =>
      paymentRef.doc(payment.id).update(payment.toJson());
  Future<void> deletePayment(Payment payment) => paymentRef.doc(payment.id).delete();




}
