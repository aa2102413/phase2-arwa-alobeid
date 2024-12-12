import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/bank_account.dart';
import '../models/cheque_deposit.dart';

class ChequeDespositRepo {
  final CollectionReference chequedepositRef;
  ChequeDespositRepo({required this.chequedepositRef});
  List<BankAccount> _bankAccounts = [];
  Stream<List<ChequeDeposit>> observeChequeDeposits() {
    return chequedepositRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ChequeDeposit.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
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

   Future< ChequeDeposit?> getChequeDepositById(int id)async {
    return null;
  }

  Future<List<ChequeDeposit>> searchChequeDeposits(String text) async {
    return [];
  }


 Future<void > addChequeDeposit(ChequeDeposit chequeDeposit) async{ }

 Future<void > deleteChequeDeposit(ChequeDeposit chequeDeposit) async{ }

Future<void > updateChequeDeposit(ChequeDeposit chequeDeposit) async{ }

Future<void > updateChequeDepositOnChequeDelete(int chequeNo) async{ }


}
