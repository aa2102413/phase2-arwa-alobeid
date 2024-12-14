import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/bank_account.dart';
import '../models/cheque_deposit.dart';

class ChequeDespositRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference chequedepositRef;
  ChequeDespositRepo() {
    chequedepositRef = _db.collection('ChequeDeposits'); }

  List<BankAccount> _bankAccounts = [];
  //FIX 
 List<ChequeDeposit> _chequeDeposits = [];
 
List<ChequeDeposit> get chequeDeposits => _chequeDeposits;
 set chequeDeposits(List<ChequeDeposit> value) => _chequeDeposits = value;

  Stream<List<ChequeDeposit>> observeChequeDeposits() {
    return chequedepositRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ChequeDeposit.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<ChequeDeposit>> initChequeDeposits() async {
    List<ChequeDeposit> chequeDeposits = [];
    final snapshot = await chequedepositRef.get();
    if (snapshot.docs.isEmpty) {
      var chequeDepositData =
          await rootBundle.loadString('assets/data/cheque-deposits.json');
      var chequeDepositsMap = jsonDecode(chequeDepositData);
      chequeDeposits = chequeDepositsMap
          .map<ChequeDeposit>(
              (chequeDeposit) => ChequeDeposit.fromJson(chequeDeposit))
          .toList();
      for (var chequeDeposit in chequeDeposits) {
        await chequedepositRef
            .doc(chequeDeposit.id.toString())
            .set(chequeDeposit.toJson());
      }
    } else {
      chequeDeposits = snapshot.docs
          .map((doc) =>
              ChequeDeposit.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }
    return chequeDeposits;
  }
  Future<List<BankAccount>> initBankAccounts() async {
    var bankAccountData =
        await rootBundle.loadString('assets/data/bank-accounts.json');
    var bankAccountsMap = jsonDecode(bankAccountData);
    _bankAccounts = bankAccountsMap
        .map<BankAccount>((bankAccount) => BankAccount.fromJson(bankAccount))
        .toList();
    return _bankAccounts;
  }
  get bankAccounts => _bankAccounts;

  Future<ChequeDeposit?> getChequeDepositById(int id) async =>
      chequedepositRef.doc(id.toString() ).get().then((snapshot) {
        return ChequeDeposit.fromJson(snapshot.data() as Map<String, dynamic>);
      });

  Future<List<ChequeDeposit>> searchChequeDeposits(String text) async {
    return [];
  }

  Future<void> addChequeDeposit(ChequeDeposit chequeDeposit) async {
    // var docId = chequedepositRef.doc().id;
    // chequeDeposit.id = int.parse(docId);
    // await chequedepositRef.doc(docId).set(chequeDeposit.toJson());
    await chequedepositRef.add(chequeDeposit.toJson());
  }

  Future<void> deleteChequeDeposit(ChequeDeposit chequeDeposit) async {
    final chequeDoc =
        await chequedepositRef.doc(chequeDeposit.id.toString()).get();
    if (chequeDoc.exists) {
      chequedepositRef.doc(chequeDeposit.id.toString()).delete();
    }
  }

  Future<void> updateChequeDeposit(ChequeDeposit chequeDeposit) async {
    String? newchequeDepositId = chequeDeposit.id.toString();
    chequedepositRef.doc(newchequeDepositId).update(chequeDeposit.toJson());
  }

  Future<void> updateChequeDepositOnChequeDelete(int chequeNo) async {
    final querySnapshot = await chequedepositRef.get();
    List<ChequeDeposit> temp = [];
    for (var doc in querySnapshot.docs) {
      final chequeDeposit =
          ChequeDeposit.fromJson(doc.data() as Map<String, dynamic>);

      if (chequeDeposit.chequeNos.contains(chequeNo)) {
        chequeDeposit.chequeNos.remove(chequeNo);
        if (chequeDeposit.chequeNos.isEmpty) {
          temp.add(chequeDeposit);
        }
        await chequedepositRef.doc(doc.id).update({
          'chequeNos': chequeDeposit.chequeNos,
        });
      }
    }

    for (var chequeDeposit in temp) {
      final docToDelete = querySnapshot.docs.firstWhere((doc) =>
          ChequeDeposit.fromJson(doc.data() as Map<String, dynamic>) ==
          chequeDeposit);
      await chequedepositRef.doc(docToDelete.id).delete();
    }
  }
}
