import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/models/cheque.dart';

import '../FB_Repositories/cheque_repo.dart';

class UpdatedChequesNotifier extends StateNotifier<List<Cheque>> {
 UpdatedChequesNotifier() : super(const []);
  late final ChequeRepo _chequeRepo;
  Future<List<Cheque>> build() async{
   _chequeRepo.observeCheques().listen((cheques) {
      state = cheques;}).onError((error) { print(error);}); return [];}
  void addCheque(Cheque cheque) {_chequeRepo.addCheque(cheque);}
 void updateChequeStatusAndCashedDate(Cheque cheque, String status, DateTime cashedDate, String returnReason) {
    state = state.map((element) {if (element.chequeNo == cheque.chequeNo) {
        return Cheque(
          element.chequeNo,
          element.amount,
          element.drawer,
          element.bankName,
          status,
          element.receivedDate,
          element.dueDate,
          element.chequeImageUri,
          returnReason,
          cashedDate,  ); } return element; }).toList();}
   void clearCheques() {state = [];}}
final updatedChequesProviderNotifier =
    StateNotifierProvider<UpdatedChequesNotifier, List<Cheque>>( (ref) => UpdatedChequesNotifier());
