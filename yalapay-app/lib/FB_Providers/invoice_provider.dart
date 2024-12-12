import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../FB_Repo_provider/invoice_repo_provider.dart';
import '../FB_Repositories/invoice_repo.dart';
import '../models/invoice.dart';
class InvoiceNotifier extends AsyncNotifier<List<Invoice>> {
 late final InvoiceRepo _invoiceRepo;

 @override
  Future<List<Invoice>> build() async {
   _invoiceRepo = await ref.watch(invoiceRepoProvider.future);
  _invoiceRepo.observeInvoices().listen((invoices) {
      state = AsyncValue.data(invoices);
    }).onError((error) {
      print(error);
    });
    return []; 
  }






}
final invoiceNotifierProvider =
    AsyncNotifierProvider<InvoiceNotifier, List<Invoice>>(
        () => InvoiceNotifier());