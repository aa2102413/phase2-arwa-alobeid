
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cheque.dart';

class ChequeRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference chequeRef;

  ChequeRepo({required this.chequeRef});

  Stream<List<Cheque>> observeCheques() {
    return chequeRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Cheque.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Cheque?> getChequeBychequeNo(String chequeNo) =>
      chequeRef.doc(chequeNo).get().then((snapshot) {
        return Cheque.fromJson(snapshot.data() as Map<String, dynamic>);
      });

  Future<void> addCheque(Cheque cheque) async {
    var docId =
        chequeRef.doc().id; //will create an empty document with a unique id
    cheque.chequeNo = int.parse(docId);
    await chequeRef.doc(docId).set(cheque.toJson());
  }

  Future<List<Cheque>> getByDate(DateTime fromDate, DateTime toDate) async {
    return [];
  }

  Future<void> updateCheque(Cheque cheque) async {}

  Future<void> deleteCheque(Cheque cheque) async {}

 Future<Cheque?> getChequeById(int id) async{
    return null;
  }

   Future<List<Cheque>> filterList(String status)async{
    return [];
  }

  Future<double> getTotalAmount(List<Cheque> cheques)async{
    double total = 0.0;
    
    return total;
  }



}
