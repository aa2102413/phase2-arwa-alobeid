
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firestore_repo/deposit_repo.dart';



final customerRepoProvider = FutureProvider<DepositRepo>((ref) async{
  var db = FirebaseFirestore.instance;
  
  return DepositRepo(depositRef: db.collection('deposits'),);

});