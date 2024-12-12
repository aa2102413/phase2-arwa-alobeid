import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cheque.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class InvoiceRepo {
  final CollectionReference invoiceRef;
  InvoiceRepo({required this.invoiceRef});

  Stream<List<Invoice>> observeInvoices() {
    return invoiceRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Invoice.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Invoice?> getInvoiceById(int id) =>
      invoiceRef.doc(id as String?).get().then((snapshot) {
        return Invoice.fromJson(snapshot.data() as Map<String, dynamic>);
      });

  Future<List<Invoice>> searchInvoices(
      String text, List<Payment> payments, List<Cheque> cheques) async {
    return [];
  }

  Future<void> addInvoice(Invoice invoice) async {
    // var docId =
    //     invoiceRef.doc().id; //will create an empty document with a unique id
    // invoice.id = docId;
    // await invoiceRef.doc(docId).set(invoice
    //     .toJson()); //it will add a new document if the doc does not exit or update if it exists
  }

 Future<void>  deleteInvoice(Invoice invoice) async {}

 Future<List<Invoice>> getByInvoiceDate(DateTime fromDate,DateTime toDate)async {
    return [];
  }


 Future<void> updateInvoice(Invoice invoice) =>invoiceRef.doc(invoice.id as String?).update(invoice.toJson());
 
}
