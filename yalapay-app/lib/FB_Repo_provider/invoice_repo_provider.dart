import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../FB_Repositories/invoice_repo.dart';

final invoiceRepoProvider = FutureProvider<InvoiceRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  return InvoiceRepo( invoiceRef: db.collection('invoices')

  );
});
 final selectedInvoiceNoProvider = StateProvider<String?>((ref) => null);