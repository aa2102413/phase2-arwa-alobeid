import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/models/cheque.dart';

class SelectedChequesProvider extends  StateNotifier<List<Cheque>> {
  SelectedChequesProvider() : super(const []);

  // List<Cheque> build() {
  //   return [];
  // }

    void clearCheques() {
    state = [];
  }
}

final selectedChequeProviderNotifier =  StateNotifierProvider<SelectedChequesProvider, List<Cheque>>((ref) => SelectedChequesProvider());