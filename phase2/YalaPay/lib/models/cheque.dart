// cheque.dart
class Cheque {
  int chequeNo;
  final double amount;
  final String drawer;
  final String bankName;
  String status; // Mutable for status updates
  final DateTime receivedDate;
  final DateTime dueDate;
 String chequeImageUri;

  Cheque({
    required this.chequeNo,
    required this.amount,
    required this.drawer,
    required this.bankName,
    required this.status,
    required this.receivedDate,
    required this.dueDate,
    required this.chequeImageUri,
  });

  factory Cheque.fromJson(Map<String, dynamic> json) {
    return Cheque(
      chequeNo: json['chequeNo'],
      amount: json['amount'],
      drawer: json['drawer'],
      bankName: json['bankName'],
      status: json['status'],
      receivedDate: DateTime.parse(json['receivedDate']),
      dueDate: DateTime.parse(json['dueDate']),
      chequeImageUri: json['chequeImageUri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chequeNo': chequeNo,
      'amount': amount,
      'drawer': drawer,
      'bankName': bankName,
      'status': status,
      'receivedDate': receivedDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'chequeImageUri': chequeImageUri,
    };
  }


 Cheque copyWith({
    int? chequeNo,
    double? amount,
    String? drawer,
    String? bankName,
    String? status,
    DateTime? receivedDate,
    DateTime? dueDate,
    String? chequeImageUri,
  }) {
    return Cheque(
      chequeNo: chequeNo ?? this.chequeNo,
      amount: amount ?? this.amount,
      drawer: drawer ?? this.drawer,
      bankName: bankName ?? this.bankName,
      status: status ?? this.status,
      receivedDate: receivedDate ?? this.receivedDate,
      dueDate: dueDate ?? this.dueDate,
      chequeImageUri: chequeImageUri ?? this.chequeImageUri,
    );
  }



}
