import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/cheque.dart';

class ChequeRepo {
  late final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference chequeRef;

  ChequeRepo() {
    chequeRef=_db.collection('cheques'); }

  List<Cheque> get cheques => cheques;
  set cheques(List<Cheque> cheques) => cheques = cheques;

  Stream<List<Cheque>> observeCheques() {
    return chequeRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Cheque.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Cheque>> initCheques() async {
    List<Cheque> cheques = [];
    final snapshot = await chequeRef.get();
    if (snapshot.docs.isEmpty) {
      var chequeData = await rootBundle.loadString('assets/data/cheques.json');
      var chequesMap = jsonDecode(chequeData);

      cheques =
          chequesMap.map<Cheque>((cheque) => Cheque.fromJson(cheque)).toList();
      for (var cheque in cheques) {
        await chequeRef.doc(cheque.chequeNo.toString()).set(cheque.toJson());
      }
    } 
    // else {
    //   // Load from Firestore
    //   cheques = snapshot.docs
    //       .map((doc) => Cheque.fromJson(doc.data() as Map<String, dynamic>))
    //       .toList();
    // }

    return cheques;
  }

  Future<Cheque?> getChequeBychequeNo(String chequeNo) =>
      chequeRef.doc(chequeNo).get().then((snapshot) {
        return Cheque.fromJson(snapshot.data() as Map<String, dynamic>);
      });

  Future<void> addCheque(Cheque cheque) async {
    var docId = chequeRef.doc().id;
    cheque.chequeNo = int.parse(docId);
    await chequeRef.doc(docId).set(cheque.toJson());
  }

  Future<List<Cheque>> getByDate(DateTime fromDate, DateTime toDate) async {
    final queryResult = await chequeRef
        .where('receivedDate', isGreaterThan: fromDate)
        .where('receivedDate', isLessThan: toDate)
        .get();
    List<Cheque> cheques = queryResult.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Cheque.fromJson(data);
    }).toList();

    return cheques;
  }

  Future<void> updateCheque(Cheque cheque) async {
    String? newchequeNo = cheque.chequeNo.toString();
    chequeRef.doc(newchequeNo).update(cheque.toJson());
  }

  Future<void> deleteCheque(Cheque cheque) async {
    final chequeDoc = await chequeRef.doc(cheque.chequeNo.toString()).get();

    if (chequeDoc.exists) {
      chequeRef.doc(cheque.chequeNo.toString()).delete();
    }
  }

  Future<Cheque> getChequeById(int id) async {
    final snapshot = await chequeRef.doc(id.toString()).get();
    return Cheque.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  Future<List<Cheque>> filterList(String status) async {
    final queryResult = await chequeRef.where('status', isEqualTo: status.toLowerCase()).get();
    List<Cheque> cheques = queryResult.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Cheque.fromJson(data);
    }).toList();

    return cheques;
  }

  Future<double> getTotalAmount(List<Cheque> cheques) async {
    double total = 0.0; //no need to make it total
    for (var cheque in cheques) {
      total += cheque.amount;
    }
    return total;
  }
}
/**double getTotalAmount(List<Cheque> cheques){
    double total = 0.0;
    for (var cheque in cheques) {
      total+=cheque.amount;
    }
    return total;
  } */
