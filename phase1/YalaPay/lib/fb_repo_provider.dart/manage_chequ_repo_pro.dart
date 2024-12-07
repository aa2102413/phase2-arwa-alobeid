import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/firestore_repo/manage_cashing_cheques_repo.dart';

final manageChashingRepoProvider =
    FutureProvider<ManageCashingChequesRepo>((ref) async {
  // TODO initialize Firestore db
  var db = FirebaseFirestore.instance;

  return ManageCashingChequesRepo(
    chequeRef: db.collection('chequws'),
    depositRef: db.collection('deposits')
  );
});
