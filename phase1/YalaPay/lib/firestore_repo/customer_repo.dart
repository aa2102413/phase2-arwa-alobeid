import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepo {
  final CollectionReference customerRef;

  CustomerRepo({required this.customerRef});
  
}
