
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firestore_repo/customer_repo.dart';

final customerRepoProvider = FutureProvider<CustomerRepo>((ref) async{
  var db = FirebaseFirestore.instance;
  return CustomerRepo(
  customerRef: db.collection('Customers'),

  );
});