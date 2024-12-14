import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/models/bank_account.dart';
import '../FB_Repositories/cheque_desposit_repo.dart';
import '../models/cheque_deposit.dart';

class ChequeDepositNotifier extends StateNotifier<List<ChequeDeposit>> {
  ChequeDepositNotifier() : super(const []);
  late final ChequeDespositRepo _chequeDespositRepo;
  List<ChequeDeposit> build() {
    initalizeState();
    return [];}
  void initalizeState() async {
    await _chequeDespositRepo.initBankAccounts();
    state = (await _chequeDespositRepo.initChequeDeposits()).reversed.toList(); }

  void searchChequeDeposits(String text) async{
    final chequeDesposits =await _chequeDespositRepo.searchChequeDeposits(text);
    state = List.from( chequeDesposits.reversed);}

  Future<ChequeDeposit?> getChequeDepositById(int id) {
    return _chequeDespositRepo.getChequeDepositById(id);}
  void addChequeDeposit(ChequeDeposit chequeDeposit) async {
    await  _chequeDespositRepo.addChequeDeposit(chequeDeposit);
    state = List.from(_chequeDespositRepo.chequeDeposits.reversed);}
  void deleteChequeDeposit(ChequeDeposit chequeDeposit) async {
    await _chequeDespositRepo.deleteChequeDeposit(chequeDeposit);
    state = List.from(_chequeDespositRepo.chequeDeposits.reversed); }
  void updateChequeDeposit(ChequeDeposit chequeDeposit)async {
    await  _chequeDespositRepo.updateChequeDeposit(chequeDeposit);
    state = List.from(_chequeDespositRepo.chequeDeposits.reversed);}
  void updateChequeDepositOnChequeDelete(int chequeId) async {
    await  _chequeDespositRepo.updateChequeDepositOnChequeDelete(chequeId);
    state = List.from(_chequeDespositRepo.chequeDeposits.reversed);}
  List<BankAccount> get bankAccounts => _chequeDespositRepo.bankAccounts;
  int getlastId() {return _chequeDespositRepo.chequeDeposits.last.id; }
  void resetState() { state = List.from(_chequeDespositRepo.chequeDeposits.reversed);
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