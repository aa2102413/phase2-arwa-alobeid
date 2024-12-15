import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/models/bank_account.dart';
import '../FB_Repositories/cheque_desposit_repo.dart';
import '../models/cheque_deposit.dart';

class ChequeDepositNotifier extends StateNotifier<List<ChequeDeposit>> {
  ChequeDepositNotifier() : super(const []){
    initalizeState();
  }
  late final ChequeDespositRepo _chequeDespositRepo;
 
  void initalizeState() async {
  // ignore: non_constant_identifier_names
  _chequeDespositRepo.observeChequeDeposits().listen((ChequeDeposits) {
      state =ChequeDeposits;
    });
    }

  void searchChequeDeposits(String text) async{
    final chequeDesposits =await _chequeDespositRepo.searchChequeDeposits(text);
    state =chequeDesposits.reversed.toList();}

  Future<ChequeDeposit?> getChequeDepositById(int id) {
    return _chequeDespositRepo.getChequeDepositById(id);}

  void addChequeDeposit(ChequeDeposit chequeDeposit) async {
    await  _chequeDespositRepo.addChequeDeposit(chequeDeposit);
   state = _chequeDespositRepo.chequeDeposits.reversed.toList();}

  void deleteChequeDeposit(ChequeDeposit chequeDeposit) async {
    await _chequeDespositRepo.deleteChequeDeposit(chequeDeposit);
    state = _chequeDespositRepo.chequeDeposits.reversed.toList(); }
    

  void updateChequeDeposit(ChequeDeposit chequeDeposit)async {
    await  _chequeDespositRepo.updateChequeDeposit(chequeDeposit);
   state = _chequeDespositRepo.chequeDeposits.reversed.toList();}

  void updateChequeDepositOnChequeDelete(int chequeId) async {
    await  _chequeDespositRepo.updateChequeDepositOnChequeDelete(chequeId);
   state = _chequeDespositRepo.chequeDeposits.reversed.toList();}

  List<BankAccount> get bankAccounts => _chequeDespositRepo.bankAccounts;
  int getlastId() {return _chequeDespositRepo.chequeDeposits.last.id; }

  void resetState() { state = _chequeDespositRepo.chequeDeposits.reversed.toList();
  }

}

final chequeDepositProvider =
    StateNotifierProvider<ChequeDepositNotifier, List<ChequeDeposit>>(
        (ref) => ChequeDepositNotifier());









//   Future<List<ChequeDeposit>> build() async {
//    //_chequeDespositRepo= await ref.watch(chequeDepositRepoProvider.future);
//  _chequeDespositRepo.observeChequeDeposits().listen((chequeDeposits) {
//       state =chequeDeposits;
//     }).onError((error) {
//       print(error);
//     });
//     return [];
//   }