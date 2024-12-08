
  //list  awating payment cheques
  //select bank account to deposite
  //list cheques deposite
  //update the status of of cheque after deposit
  //-------------------------------


import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cheque.dart';

class ChequeRepo {

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference chequeRef;
   final CollectionReference chequeDepositsRef;


  ChequeRepo({required this.chequeRef, required this.chequeDepositsRef});


  Stream<List<Cheque>> observeCheques() { // Fetch cheques
    return chequeRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Cheque.fromJson(doc.data() as Map<String, dynamic>))
          .toList();});}


   //------------

  // Stream<List<Cheque>> searchByChequeNo(List<Cheque> cheques, String chequeNo){}

  Future<Cheque?> getChequeBychequeNo(String chequeNo) =>
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

  Future<void> deleteCheque(int chequeNo) async {
    // final chequeRef = _firestore.collection('Cheques').doc(chequeNo.toString());
    final chequeDoc = await chequeRef.doc(chequeNo.toString()).get();
  if (chequeDoc.exists) {
      String imageUrl = chequeDoc.get('chequeImageUri');
      if (imageUrl.isNotEmpty) {
        await deleteChequeImage(imageUrl);
      }
      await chequeDoc.reference.delete();}}


  //------------

Future<void> deleteChequeImage(String imageUrl) async {
    await _storage.refFromURL(imageUrl).delete();}

  //------------

Future<String> _uploadChequeImage(int chequeNo, File imageFile) async {
    Reference storageRef = _storage.ref().child('cheque_images/$chequeNo.jpg');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL(); }


  //------------

  Future<void> updateCheque(Cheque cheque) async {
    String? newchequeNo =cheque.chequeNo.toString();
    chequeRef.doc(newchequeNo).update(cheque.toJson()); }


  Future<void> createDeposit(List<int> chequeNos, String bankAccountNo) async {
    final depositDate = DateTime.now();
   final depositId= DateTime.now().millisecondsSinceEpoch.toString(); //fixx HEREEEE

  chequeDepositsRef.doc(depositId).set({
    'id': depositId,
    'depositDate': depositDate,
    'bankAccountNo': bankAccountNo,
    'status': 'Deposited',
    'chequeNos': chequeNos,
  });
  for (final chequeNo in chequeNos) {
    await chequeRef.doc(chequeNo.toString()).update({
      'status': 'Deposited',
      'depositDate': depositDate, });}}



Future<void> addChequeWithImage(Cheque cheque, File imageFile) async {
    String imageUrl = await _uploadChequeImage(cheque.chequeNo, imageFile);
    cheque = cheque.copyWith(chequeImageUri: imageUrl);
   await chequeRef.doc(cheque.chequeNo.toString()).set(cheque.toJson()); }



// Update the status of selected cheques
Future<void> updateChequesStatus(List<int> selectedChequeNos) async {
  try {
    // Use a batch operation for updating multiple cheques atomically
    WriteBatch batch = firestore.batch();

    for (int chequeNo in selectedChequeNos) {
      DocumentReference chequeDoc =chequeRef.doc(chequeNo.toString());
      batch.update(chequeDoc, {'status': 'Deposited'});
    }
    // Commit the batch
    await batch.commit();
    print("Successfully updated cheque statuses to 'Deposited'");
  } catch (e) {
    print("Error updating cheque statuses: $e");}}



  //Deposits

  Future<void> updateDepositStatus(String depositId, String status,
    {DateTime? cashedDate, DateTime? returnDate, String? returnReason}) async {
  final depositRef = chequeDepositsRef.doc(depositId);
  final deposit = await depositRef.get();

  if (deposit.exists) {
    final chequeNos = List<int>.from(deposit.get('chequeNos'));
    await depositRef.update({
      'status': status,
      'cashedDate': cashedDate?.toIso8601String(),
      'returnReason': returnReason,
    });

    for (final chequeNo in chequeNos) {
      await chequeRef.doc(chequeNo.toString()).update({
        'status': status == 'Cashed' ? 'Cashed' : 'Returned',
        'cashedDate': cashedDate?.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
      });
    }
  }
}




// Append a new deposit entry to cheque-deposits.json
  Future<void> appendDepositToFile(Map<String, dynamic> newDeposit) async {
    try {
      final path = await _depositsFilePath;
      final file = File(path);

      // Load existing deposits, append the new deposit, and save back
      final depositsData = await file.readAsString();
      List depositsJson = jsonDecode(depositsData);
      depositsJson.add(newDeposit);

      await file.writeAsString(jsonEncode(depositsJson),
          mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error writing to cheque-deposits.json: $e");
    }
  }


//---------------------------------------------
  // Debugging function to check content in the cheques file
  void debugFileContent() async {
    final path = await _chequesFilePath;
    final chequesData = await File(path).readAsString();
    print("Cheques JSON content: $chequesData");
  }




 Future<String> get _chequesFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/cheques.json';
  }

  Future<String> get _depositsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/cheque-deposits.json';
  }

  Future<void> resetData() async {
    final chequesPath = await _chequesFilePath;
    final depositsPath = await _depositsFilePath;

    await File(chequesPath).writeAsString(jsonEncode([]));
    await File(depositsPath).writeAsString(jsonEncode([]));
  }

 
}















  // Future<void> addCheque(Cheque newCheque) async {
  //   try {
  //     final path = await _chequesFilePath;
  //     final file = File(path);
  //     final chequesData = await file.readAsString();
  //     List chequesJson = jsonDecode(chequesData);

  //     chequesJson.add(newCheque
  //         .toJson()); // Convert newCheque to JSON and add it to the list
  //     await file.writeAsString(jsonEncode(chequesJson),
  //         mode: FileMode.write, flush: true);
  //   } catch (e) {
  //     print("Error adding cheque: $e");
  //   }
  // }


  // Update an existing cheque in the list
  // void updateCheque(List<Cheque> cheques, Cheque updatedCheque) {
  //   for (int i = 0; i < cheques.length; i++) {
  //     if (cheques[i].chequeNo == updatedCheque.chequeNo) {
  //       cheques[i] = updatedCheque;
  //       break;
  //     }
  //   }
  // }

  // List<Cheque> searchByChequeNo(List<Cheque> cheques, int? chequeNo) {
  //   if (chequeNo == null) return [];
  //   return cheques.where((cheque) => cheque.chequeNo == chequeNo).toList();
  // }

// Define the provider
//final chequeRepositoryProvider = Provider((ref) => ChequeRepo());











