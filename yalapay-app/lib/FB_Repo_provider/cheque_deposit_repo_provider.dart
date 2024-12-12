
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../FB_Repositories/cheque_desposit_repo.dart';


final chequeDepositRepoProvider = FutureProvider< ChequeDespositRepo>((ref) async{
  var db = FirebaseFirestore.instance;
  return  ChequeDespositRepo(chequedepositRef: db.collection('ChequeDeposits')
  );
});