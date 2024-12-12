import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../FB_Repo_provider/cheque_deposit_repo_provider.dart';
import '../FB_Repositories/cheque_desposit_repo.dart';
import '../models/cheque_deposit.dart';


class ChequeDepositNotifier extends AsyncNotifier<List<ChequeDeposit>> {
 late final  ChequeDespositRepo _chequeDespositRepo;

 @override
  Future<List<ChequeDeposit>> build() async {
   _chequeDespositRepo= await ref.watch(chequeDepositRepoProvider.future);
 _chequeDespositRepo.observeChequeDeposits().listen((chequeDeposits) {
      state = AsyncValue.data(chequeDeposits);
    }).onError((error) {
      print(error);
    });
    return []; 
  }






}
final chequeDepositNotifierProvider =
    AsyncNotifierProvider<ChequeDepositNotifier, List<ChequeDeposit>>(
        () => ChequeDepositNotifier());