import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceRepo {
  final CollectionReference invoiceRef;

  InvoiceRepo({required this.invoiceRef});
}
