import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalapay/FB_Providers/cheque_deposit_provider.dart';
import 'package:yalapay/FB_Providers/cheque_provider.dart';
import 'package:yalapay/FB_Providers/update_cheques_provider.dart';
import 'package:yalapay/data_classes/cheque_deposit_args.dart';
import 'package:yalapay/models/cheque.dart';
import 'package:yalapay/models/cheque_deposit.dart';
import 'package:yalapay/models/simpleDate.dart';

import 'package:yalapay/routes/app_router.dart';

class AccordianChequesDeposit extends ConsumerStatefulWidget {
  final ChequeDeposit chequeDeposit;
  const AccordianChequesDeposit({super.key, required this.chequeDeposit});

  @override
  ConsumerState<AccordianChequesDeposit> createState() =>
      _AccordianChequesDepositState();
}

class _AccordianChequesDepositState
    extends ConsumerState<AccordianChequesDeposit> {
    final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<String> _imageUrls = [];
  List<String> _imageNames = [];
  bool isIconUp = false;
  List<Cheque> selectedCheques = [];
  double amountPaid = 0.0;
  double amountDue = 0.0;

 @override
  void initState() {
    super.initState();
    _loadImages();
  }
  Future<void> _fetchChequeDetails() async {
    final readChequeNotifier = ref.watch(chequeNotifierProvider.notifier);
    selectedCheques.clear();
    amountPaid = 0;
    amountDue = 0;

    for (var cheque in widget.chequeDeposit.chequeNos) {
      final chequeData = await readChequeNotifier.getChequeById(cheque);
      if (chequeData == null) continue;

      if (selectedCheques.contains(chequeData)) continue;
      selectedCheques.add(chequeData);

      if (chequeData.status == 'Cashed') { amountPaid += chequeData.amount;
      } else {  amountDue += chequeData.amount;
      }
    }
  }

   Future<void> _loadImages() async {
    try {
      final files = await _supabaseClient.storage.from('images').list();
      final List<String> urls = files
          .map((file) =>
              _supabaseClient.storage.from('images').getPublicUrl(file.name))
          .toList();
      final List<String> names = files.map((file) => file.name).toList();
      setState(() {
        _imageUrls = urls;
        _imageNames = names;
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading images: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteImage(int index) async {
    try { await _supabaseClient.storage.from('images').remove([_imageNames[index]]);
      setState(() {
        _imageUrls.removeAt(index);
        _imageNames.removeAt(index); });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      ); } catch (e) {ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: ${e.toString()}')),
      );}}


  @override
  Widget build(BuildContext context) {
    final readChequeDepositNotifier = ref.read(chequeDepositProvider.notifier);
    final readUpdatedChequesProvider =
        ref.watch(updatedChequesProviderNotifier.notifier);

    return FutureBuilder<ChequeDeposit?>(
        future: readChequeDepositNotifier
            .getChequeDepositById(widget.chequeDeposit.id),
        builder:
            (BuildContext context, AsyncSnapshot<ChequeDeposit?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Cheque Deposit not found.'));
          } else {
            final chequeDeposit = snapshot.data!;
            return GestureDetector(
              child: ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: chequeDeposit.status == 'Cashed'
                                ? Colors.green.withOpacity(0.15)
                                : chequeDeposit.status == 'Cashed with Returns'
                                    ? Colors.blue.withOpacity(0.15)
                                    : chequeDeposit.status == 'Returned'
                                        ? Colors.red.withOpacity(0.15)
                                        : Colors.amber.shade600
                                            .withOpacity(0.15),
                          ),
                          alignment: Alignment.center,
                          child: Text( widget.chequeDeposit.status,
                            style: TextStyle(
                                color: chequeDeposit.status == 'Cashed'
                                    ? Colors.green
                                    : chequeDeposit.status == 'Cashed with Returns'
                                        ? Colors.blue
                                        : chequeDeposit.status == 'Returned'
                                            ? Colors.red
                                            : Colors.amber.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        amountPaid > amountDue
                            ? Text(
                                'QR $amountPaid PAID',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green),
                              )
                            : Text(  'QR $amountDue DUE',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.red),
                              ),
                        Row(
                          children: [
                            Text(
                              '${SimpleDate(widget.chequeDeposit.depositDate.year, widget.chequeDeposit.depositDate.month, widget.chequeDeposit.depositDate.day)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isIconUp
                                      ? setIsIconUp(false): setIsIconUp(true);
                                }); },
                              icon: Icon(
                                isIconUp
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isIconUp)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details: (ID: ${widget.chequeDeposit.id})',
                            style: const TextStyle(  fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [  const Row(
                                        children: [
                                          Text(  'No. of Cheques: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),   ),
                                          SizedBox(width: 4),
                                        ],
                                      ),
                                      Text('${widget.chequeDeposit.chequeNos.length}',
                                          style: TextStyle(fontSize: 12)),
                                      const SizedBox(height: 8.0),
                                      const Row( children: [
                                          Text( 'Amount Paid: ', style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          SizedBox(width: 4),
                                        ],
                                      ),
                                      Text('\$$amountPaid', style: TextStyle(fontSize: 12))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text(
                                            'Amount Due: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          SizedBox(height: 0, width: 10),
                                        ],
                                      ),
                                      Text('\$$amountDue', style: TextStyle(fontSize: 12)),
                                      const Row(
                                        children: [  Text(  'Bank Account No: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Text(widget.chequeDeposit.bankAccountNo,
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text('Cheque No\'s:',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: Row(
                                    children: widget.chequeDeposit.chequeNos .map((chequeNo) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        margin:const EdgeInsets.only(right: 4.0),
                                        decoration: BoxDecoration(
                                          color: chequeDeposit.status == 'Cashed'
                                              ? Colors.green.withOpacity(0.15)
                                              : chequeDeposit.status == 'Deposited'
                                                  ? Colors.amber.shade600.withOpacity(0.15)
                                                  : chequeDeposit.status =='Returned' ?
                                        Colors.red .withOpacity(0.15) : Colors.blue .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text( '$chequeNo',  style: TextStyle(
                                              color: chequeDeposit.status == 'Cashed' ? Colors.green
                                                  : chequeDeposit.status == 'Deposited'
                                                      ? Colors.amber.shade600
                                                      : chequeDeposit.status == 'Returned'
                                                          ? Colors.red
                                                          : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                    width: 105,
                                    height: 30,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Column(crossAxisAlignment:CrossAxisAlignment.start,
                                                    children: [Text( 'Cheques Details.',
                                                        style: TextStyle( fontWeight: FontWeight.bold,  fontSize: 16), ),
                                                      Divider( color: Colors.black),
                                                    ],
                                                  ),
                                                  content:  SingleChildScrollView(
                                                    child: Column(  children: [
                                                        for (var cheque  in selectedCheques)
                                                          ListTile( title: Row(
                                                              children: [ const Text( 'Cheque No: ',
                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                                ),
                                                                Text(cheque .chequeNo.toString(),  style: TextStyle(fontSize: 12)), ],
                                                            ),
                                                            subtitle: Column( crossAxisAlignment:CrossAxisAlignment .start,
                                                              children: [ Row(
                                                                  children: [   const Text( 'Amount: ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight .bold, fontSize:  12),
                                                                    ),
                                                                    Text('\$${cheque.amount}',
                                                                        style: TextStyle(fontSize: 12)),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Text( 'Drawer: ', style: TextStyle( fontWeight: FontWeight .bold, fontSize: 12),
                                                                    ),
                                                                    Text( cheque .drawer,
                                                                        style: TextStyle( fontSize:12)),
                                                                  ],  ),
                                                                Row( children: [
                                                                    const Text('Bank: ',
                                                                      style: TextStyle(fontWeight: FontWeight .bold,   fontSize: 12),
                                                                    ),
                                                                    Text(  cheque.bankName,  style: TextStyle( fontSize: 12)),
                                                                  ],),
                                                                Row(children: [
                                                                    const Text('Status: ', style: TextStyle(
                                                                          fontWeight: FontWeight.bold,fontSize: 12),
                                                                    ),
                                                                    Text( cheque.status,  style: TextStyle( fontSize:12)),
                                                                  ], ),
                                                                Row(
                                                                  children: [const Text( 'Received Date: ',
                                                                      style: TextStyle( fontWeight: FontWeight
                                                                              .bold, fontSize:12), ),
                                                                    Text(  '${SimpleDate(cheque.receivedDate.year, cheque.receivedDate.month, cheque.receivedDate.day)}',
                                                                        style: TextStyle(fontSize: 12)),
                                                                  ],
                                                                ),
                                                                Row(children: [
                                                                    const Text( 'Due Date: ',  style: TextStyle(
                                                                          fontWeight: FontWeight .bold, fontSize: 12),  ),
                                                                    Text( '${SimpleDate(cheque.dueDate.year, cheque.dueDate.month, cheque.dueDate.day)}',
                                                                        style: TextStyle(fontSize:12)), ],
                                                                ),
                                                                (cheque.status ==  'Cashed' ||
                                                                        cheque.status =='Returned')
                                                                    ? Row(children: [ Text( cheque.status == 'Cashed'
                                                                                ? 'Cashed Date:'
                                                                                : 'Returned Date:',
                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                                          ),
                                                                          Text(
                                                                              '${SimpleDate(cheque.cashedDate.year, cheque.cashedDate.month, cheque.cashedDate.day)}',
                                                                              style: TextStyle(fontSize: 12)),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                cheque.status ==
                                                                        'Returned'
                                                                    ? Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'Returned Reason: ',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              cheque.returnReason,
                                                                              softWrap: true,
                                                                              overflow: TextOverflow.visible,
                                                                              style: TextStyle(fontSize: 12),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                    height:
                                                                        8.0),
                                                                cheque.chequeImageUri
                                                                        .isNotEmpty
                                                                    ? Image.asset(
                                                                        'assets/cheques/${cheque.chequeImageUri}')
                                                                    : const Text(
                                                                        'No Image Available.'),
                                                                const Divider(
                                                                  color: Colors
                                                                      .black,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 5,
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('Close',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[700],
                                        ),
                                        child: const Text(
                                          'Cheques',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    for (var cheque in selectedCheques) {
                                      if (!readUpdatedChequesProvider
                                          .chequeExists(cheque)) {
                                        readUpdatedChequesProvider
                                            .addCheque(cheque);
                                      } }

                                     GoRouter.of(context).go(
                                      '${AppRouter.chequeDeposit.path}${AppRouter.addChequeDeposit.path}',
                                      extra: ChequeDepositArgs(
                                          isAdd: false,
                                          chequeDeposit: widget.chequeDeposit),
                                    );
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Delete Cheque Deposit',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: const Text(
                                                'Are you sure you want to delete this Cheque Deposit? \nThis cannot be undone. \nAll related cheques will be set to "Awaiting" status.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  for (var cheque
                                                      in selectedCheques) {
                                                    ////CHECK
                                                    chequeDeposit.status =
                                                        'Awaiting';
                                                  }
                                                  readChequeDepositNotifier
                                                      .deleteChequeDeposit(
                                                          widget.chequeDeposit);
                                                          

                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            );
          }
        });
  }
void setIsIconUp(bool value) { setState(() { isIconUp = value;  }); }
}


