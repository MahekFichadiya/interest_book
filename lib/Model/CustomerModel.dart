class Customer {
  String? custId;
  final String custName;
  final String custPhn;
  String? custAddress;
  final String date;
  final String userId;

  Customer({
    this.custId,
    required this.custName,
    required this.custPhn,
    this.custAddress,
    required this.date,
    required this.userId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        custId: json['custId'] ?? '',
        custName: json['custName'] ?? '',
        custPhn: json['custPhn'] ?? '',
        custAddress: json['custAddress'] ?? '',
        date: json['date'] ?? '',
        userId: json['userId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'custId': custId,
      'custName': custName,
      'custPhn': custPhn,
      'custAddress': custAddress,
      'date': date,
      'userId': userId,
    };
  }
}
