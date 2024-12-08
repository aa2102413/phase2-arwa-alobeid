import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmart/models/bank_account.dart';
import 'package:quickmart/models/cheque.dart';

class ManageCashingChequesRepo {
  final CollectionReference chequeRef;
  final CollectionReference bankaccountRef;

  ManageCashingChequesRepo(
      {required this.chequeRef, required this.bankaccountRef});

  //list  awating payment cheques
  //select bank account to deposite
  //list cheques deposite
  //update the status of of cheque after deposit

  //cheques
  Stream<List<Cheque>> observeCheques() {
    return chequeRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Cheque.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Cheque?> getChequeById(String chequeNo) =>
      chequeRef.doc(chequeNo).get().then((snapshot) {
        return Cheque.fromJson(snapshot.data() as Map<String, dynamic>);
      });

  Future<void> addCheque(Cheque cheque) async {
    var docId =
        chequeRef.doc().id; //will create an empty document with a unique id
    cheque.chequeNo = int.parse(docId);
    await chequeRef.doc(docId).set(cheque
        .toJson()); //it will add a new document if the doc does not exit or update if it exists
  }

  Future<void> updateCheque(Cheque cheque) async {
    String? newchequeNo =cheque.chequeNo.toString();
    chequeRef.doc(newchequeNo).update(cheque.toJson());
  }

//bank accounts

  Stream<List<Cheque>> observebankaccount() {
    return bankaccountRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Cheque.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<BankAccount?> getbankaccountByaccountName(String accountName) =>
     bankaccountRef.doc(accountName).get().then((snapshot) {
        return BankAccount.fromJson(snapshot.data() as Map<String, dynamic>);
      });




}
