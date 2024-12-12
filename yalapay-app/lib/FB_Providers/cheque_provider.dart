import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../FB_Repo_provider/cheque_repo_providr.dart';
import '../FB_Repositories/cheque_repo.dart';
import '../models/cheque.dart';


class ChequeNotifier extends AsyncNotifier<List<Cheque>> {
 late final ChequeRepo _chequeRepo;

 @override
  Future<List<Cheque>> build() async {
   _chequeRepo= await ref.watch(chequeRepoProvider.future);
 _chequeRepo.observeCheques().listen((cheques) {
      state = AsyncValue.data(cheques);
    }).onError((error) {
      print(error);
    });
    return []; 
  }






}
final chequeNotifierProvider =
    AsyncNotifierProvider<ChequeNotifier, List<Cheque>>(
        () => ChequeNotifier());