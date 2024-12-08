import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quickmart/models/bank_account.dart';
import 'package:quickmart/models/cheque.dart';

class ManageCashingChequesRepo {
  final CollectionReference chequeRef;
  final CollectionReference bankaccountRef;

  ManageCashingChequesRepo(
      {required this.chequeRef, required this.bankaccountRef});
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //cheques

  Stream<List<Cheque>> observeCheques() { // Fetch cheques
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

  // Add or update cheque
  Future<void> saveCheque(Cheque cheque, File? imageFile) async {
    if (imageFile != null) {
      final ref = _storage.ref().child('cheque_images/${cheque.chequeNo}.jpg');
      final uploadTask = await ref.putFile(imageFile);
      cheque.chequeImageUri = await uploadTask.ref.getDownloadURL();
    }
    chequeRef.doc(cheque.chequeNo.toString()).set(cheque.toJson());
  }

  //------------

// Delete cheque
  Future<void> deleteCheque(int chequeNo) async {
    // final chequeRef = _firestore.collection('Cheques').doc(chequeNo.toString());
    final chequeDoc = await chequeRef.doc(chequeNo.toString()).get();

    if (chequeDoc.exists) {
      final cheque = Cheque.fromJson(chequeDoc.data() as Map<String, dynamic>);
      if (cheque.chequeImageUri.isNotEmpty) {
        final ref = _storage.refFromURL(cheque.chequeImageUri);
        await ref.delete();
      }
    //  await chequeRef.delete();
    }
  }



  //------------

  Future<void> updateCheque(Cheque cheque) async {
    String? newchequeNo =cheque.chequeNo.toString();
    chequeRef.doc(newchequeNo).update(cheque.toJson());
  }
//////-------------------





/////-------------------






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
