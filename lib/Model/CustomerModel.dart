class Customer {
  String? custId;
  final String custName;
  final String custPhn;
  String? custAddress;
  String? custPic;
  final String date;
  final String userId;

  Customer({
    this.custId,
    required this.custName,
    required this.custPhn,
    this.custAddress,
    this.custPic,
    required this.date,
    required this.userId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        custId: json['custId'] ?? '',
        custName: json['custName'] ?? '',
        custPhn: json['custPhn'] ?? '',
        custAddress: json['custAddress'] ?? '',
        custPic: json['custPic'] ?? '',
        date: json['date'] ?? '',
        userId: json['userId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'custId': custId,
      'custName': custName,
      'custPhn': custPhn,
      'custAddress': custAddress,
      'custPic': custPic,
      'date': date,
      'userId': userId,
    };
  }
}
