import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/models/cheque_image.dart';
import '../FB_Repositories/cheque_repo.dart';
import '../models/cheque.dart';


class ChequeNotifier extends StateNotifier<List<Cheque>> {
  ChequeNotifier() : super(const []);
 late final ChequeRepo _chequeRepo;

//  Future<List<Cheque>> build() async {
//  //_chequeRepo= await ref.watch(chequeRepoProvider.future);
//  _chequeRepo.observeCheques().listen((cheques) {
//       state = cheques;
//     }).onError((error) {
//       print(error);
//     });
//     return []; 
//   }

 final chequeImages = (List<ChequeImage>.generate(7, (index) => ChequeImage(id: index+100, image: 'cheque${index + 1}.jpg')));

  List<Cheque> build() {
    initalizeState();
    return [];
  }

  void initalizeState() async {
     state = (await _chequeRepo.initCheques()).reversed.toList();
  }

  Future<Cheque?> getChequeById(int id) {
    return _chequeRepo.getChequeById(id);
  }
  
   void getByDate(DateTime fromDate,DateTime toDate)async{
    state = ( await _chequeRepo.getByDate(fromDate, toDate)).reversed.toList();
  }

void addCheque(Cheque cheque) async{
  await  _chequeRepo.addCheque(cheque);
   state = List.from(_chequeRepo.cheques.reversed);
  }

 void updateCheque(Cheque cheque)  async{
  await _chequeRepo.updateCheque(cheque);
    state = List.from(_chequeRepo.cheques.reversed);
    
  }

  Future <List<Cheque> >filterList(String status)async{
    return List.from(await _chequeRepo.filterList(status));
  }

  void deleteCheque(Cheque cheque)async{
  await _chequeRepo.deleteCheque(cheque);
    state = List.from(_chequeRepo.cheques.reversed);
  }

  Future<double> getTotalAmount(List<Cheque> cheques) =>_chequeRepo.getTotalAmount(cheques);
  

  (List<Cheque>, int amount, double totalAmount) filterChequeReport(DateTime fromDate, DateTime toDate, String status){
    List<Cheque> cheques = List.from(_chequeRepo.cheques);
    int length = 0;

    if(status != 'All'){
      cheques = cheques.where((element) => element.status.toLowerCase() == status.toLowerCase() && element.receivedDate.isAfter(fromDate) && element.receivedDate.isBefore(toDate)).toList();
    }
    else{
      cheques = cheques.where((element) => element.receivedDate.isAfter(fromDate) && element.receivedDate.isBefore(toDate)).toList();
    }

    length = cheques.length;

    double total = 0.0;

    for (var cheque in cheques) {
      total+=cheque.amount;
    }

    return (cheques, length, total);
  }

  void resetState() {
    state = List.from(_chequeRepo.cheques.reversed);
  }




}
final chequeNotifierProvider =
   StateNotifierProvider<ChequeNotifier, List<Cheque>>(
        (ref) => ChequeNotifier());