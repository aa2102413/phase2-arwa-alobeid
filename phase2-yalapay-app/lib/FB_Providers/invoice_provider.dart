import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/FB_Providers/cheque_provider.dart';
import 'package:yalapay/FB_Providers/payment_provider.dart';
import 'package:yalapay/models/cheque.dart';
import 'package:yalapay/models/payment.dart';


import '../FB_Repositories/invoice_repo.dart';
import '../models/invoice.dart';

class InvoiceNotifier extends StateNotifier<List<Invoice>> {
 late final InvoiceRepo _invoiceRepo;

  InvoiceNotifier() : super(const []) {
    _invoiceRepo = InvoiceRepo(); 
    initalizeState();
  }
 
  void initalizeState(){
   _invoiceRepo.observeInvoices().listen(( invoices) {
      state = invoices;
     }).onError((error) {
      print("Error observing invoices: $error");
    });
 
  }
Stream<List<Invoice>> observeInvoices()=> _invoiceRepo.observeInvoices();


  Future<Invoice?> getInvoiceById(int id) async {
    return await _invoiceRepo.getInvoiceById(id);
  }

  void searchInvoices(String text) async {
    final watchPayment = paymentNotifierProvider;
    final watchCheque = chequeNotifierProvider;
    state = await _invoiceRepo.searchInvoices(text, watchPayment as List<Payment>, watchCheque as List<Cheque>);
    
  }

   Future<void> addInvoice(Invoice invoice) async {
    await _invoiceRepo.addInvoice(invoice);
    state = _invoiceRepo.invoices.reversed.toList();
  }

   Future<void> deleteInvoice(Invoice invoice) async {
    await _invoiceRepo.deleteInvoice(invoice);
    state = state.where((e) => e.id != invoice.id).toList();
  }

  int getlastId() {
    return _invoiceRepo.invoices.last.id;
  }

   Future<void> updateInvoice(Invoice invoice) async{
   await _invoiceRepo.updateInvoice(invoice);
      state = List.from( _invoiceRepo.invoices.reversed);
  }

  void getByInvoiceDate(DateTime fromDate, DateTime toDate) async {
    await _invoiceRepo.getByInvoiceDate(fromDate, toDate);
 state = (await _invoiceRepo.getByInvoiceDate(fromDate, toDate)).reversed.toList();
  }

void resetState() {
  state =_invoiceRepo.invoices.reversed.toList();
}

}

final invoiceNotifierProvider =
    StateNotifierProvider<InvoiceNotifier, List<Invoice>>(
        (ref) => InvoiceNotifier());




  // (List<Invoice> invoices, int count, double amount) filterInvoices(
  //     DateTime fromDate, DateTime toDate, String status) {
  //   var invoices = _invoiceRepo.initInvoices();
  //   var payments = ref.watch(paymentNotifierProvider);

  //   Future<List<Invoice>> all = invoices.where((element) =>
  //           element.invoiceDate.isAfter(fromDate) &&
  //           element.invoiceDate.isBefore(toDate)).toList();
  //   List<Invoice> paid = [];
  //   List<Invoice> partiallyPaid = [];
  //   List<Invoice> pending = [];

  //   double paidTotal = 0;
  //   double partiallyPaidTotal = 0;
  //   double pendingTotal = 0;

  //   for (var i in invoices) {
  //     double amount = 0;
  //     if (i.invoiceDate.isBefore(toDate) && i.invoiceDate.isAfter(fromDate)) {
  //       for (var p in payments) {
  //         if (i.id == p.invoiceNo) {
  //           if (p.paymentMode.toLowerCase() == "cheque") {
  //             var cheque = ref
  //                 .read(chequeNotifierProvider.notifier)
  //                 .getChequeById(p.chequeNo);
  //             if (cheque.status.toLowerCase() == "cashed") {
  //               amount += cheque.amount;
  //             }
  //           } else {
  //             amount += p.amount;
  //           }
  //         }
  //       }

  //       if (amount == i.amount) {
  //         paid.add(i);
  //         paidTotal += amount;
  //       } else if (amount > 0 && amount < i.amount) {
  //         partiallyPaid.add(i);
  //         partiallyPaidTotal += amount;
  //       } else {
  //         pending.add(i);
  //         pendingTotal += i.amount;
  //       }
  //     }
  //   }

  //   if (status.toLowerCase() == "paid") {
  //     return (paid, paid.length, paidTotal);
  //   } else if (status.toLowerCase() == "partially paid") {
  //     return (partiallyPaid, partiallyPaid.length, partiallyPaidTotal);
  //   } else if (status.toLowerCase() == "pending") {
  //     return (pending, pending.length, pendingTotal);
  //   } else {
  //     if (all.isEmpty) {
  //       return (all, all.length, 0);
  //     }
  //     return (all, all.length, paidTotal + partiallyPaidTotal + pendingTotal);
  //   }
  // }
