import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/fb_repo_provider.dart/payment_repo_provider.dart';

import '../firestore_repo/payments_repo.dart';
import '../models/invoice.dart';

class InvoiceNotifier extends AsyncNotifier<List<Invoice>> {
 late final PaymentRepo _paymentRepo;

 @override
  Future<List<Invoice>> build() async {
   _paymentRepo = await ref.watch(paymentRepoProvider.future);

    // Listen to the stream and emit the data
   _paymentRepo.observeInvoices().listen((invoices) {
      state = AsyncValue.data(invoices);
    }).onError((error) {
      print(error);
    });

    return []; // Initial empty state
  }


  //-----------


  void addInvoice(Invoice invoice) async {
    await _paymentRepo.addInvoice(invoice);}
   
  //-----------


  void updateInvoice(Invoice invoice) async {
    try {
      await _paymentRepo.updateInvoice(invoice);
    } catch (e) {
      print(e);
    } }


  //-----------

  void deleteInvoice(Invoice invoice) async {
    await _paymentRepo.deleteInvoice(invoice);
  }
  
  //-----------


}
final invoiceNotifierProvider =
    AsyncNotifierProvider<InvoiceNotifier, List<Invoice>>(
        () => InvoiceNotifier());
