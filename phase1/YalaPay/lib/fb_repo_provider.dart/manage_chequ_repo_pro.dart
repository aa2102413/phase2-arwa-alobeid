import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/firestore_repo/manage_cashing_cheques_repo.dart';

final manageChashingRepoProvider =
    FutureProvider<ManageCashingChequesRepo>((ref) async {
  var db = FirebaseFirestore.instance;

  return ManageCashingChequesRepo(
    chequeRef: db.collection('cheques'),
    bankaccountRef: db.collection('bankaccounts')
  );
});
