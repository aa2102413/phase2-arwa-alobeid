import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChequeCheckedProvider extends  StateNotifier<bool> {

  ChequeCheckedProvider() : super(const [] as bool);


  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}

final chequeCheckProviderNotifier = StateNotifierProvider<ChequeCheckedProvider, bool>((ref) => ChequeCheckedProvider());