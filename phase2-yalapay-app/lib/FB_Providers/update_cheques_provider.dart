import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/models/cheque.dart';

import '../FB_Repositories/cheque_repo.dart';

class UpdatedChequesNotifier extends StateNotifier<List<Cheque>> {
UpdatedChequesNotifier() : super(const []){ 
    initializeState();

}
  late final ChequeRepo _chequeRepo;

  void initializeState() {
    _chequeRepo.observeCheques().listen((cheques) {
      state = cheques;
    }).onError((error) {
      print("Error observing cheques: $error");
    });
  }

    void addCheque(Cheque cheque) async {
    await _chequeRepo.addCheque(cheque);
    state = _chequeRepo.cheques.reversed.toList();
  }


 void updateChequeStatusAndCashedDate(Cheque cheque, String status, DateTime cashedDate, String returnReason) {
  final updatedState = state.map((element) {
    if (element.chequeNo == cheque.chequeNo) {
      return element.copyWith(
        status: status,
        cashedDate: cashedDate,
        returnReason: returnReason,
      );
    }
    return element;
  }).toList();

  state = updatedState;
}

   void clearCheques() {state = [];}
   
   bool chequeExists(Cheque cheque) {
    return state.any((element) => element.chequeNo == cheque.chequeNo);
  }
   
   }
final updatedChequesProviderNotifier =
    StateNotifierProvider<UpdatedChequesNotifier, List<Cheque>>( (ref) => UpdatedChequesNotifier());
