
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/firestore_repo/cheque_repo.dart';

final chequeRepoProvider = FutureProvider<ChequeRepo>((ref) async{
  var db = FirebaseFirestore.instance;
  return ChequeRepo(
  chequeRef: db.collection('cheques'),
  chequeDepositsRef: db.collection('ChequeDeposits')
  );
});
