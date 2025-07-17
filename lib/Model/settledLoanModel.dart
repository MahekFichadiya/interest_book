class Settledloanmodel {
  Settledloanmodel({
    required this.loanId,
    required this.amount,
    required this.rate,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.note,
    required this.updatedAmount,
    required this.type,
    required this.userId,
    required this.custId,
    required this.custName,
    required this.paymentMode,
  });
  late final String loanId;
  late final String amount;
  late final String rate;
  late final String startDate;
  late final String endDate;
  late final String image;
  late final String note;
  late final String updatedAmount;
  late final String type;
  late final String userId;
  late final String custId;
  late final String custName;
  late final String paymentMode;
  
  Settledloanmodel.fromJson(Map<String, dynamic> json){
    loanId = (json['loanId'] ?? '').toString();
    amount = (json['amount'] ?? '').toString();
    rate = (json['rate'] ?? '').toString();
    startDate = (json['startDate'] ?? '').toString();
    endDate = (json['endDate'] ?? '').toString();
    image = (json['image'] ?? '').toString();
    note = (json['note'] ?? '').toString();
    updatedAmount = (json['updatedAmount'] ?? '').toString();
    type = (json['type'] ?? '').toString();
    userId = (json['userId'] ?? '').toString();
    custId = (json['custId'] ?? '').toString();
    // Handle custName with better fallback logic
    String rawCustName = (json['custName'] ?? '').toString().trim();
    custName = rawCustName.isNotEmpty && rawCustName != 'null' ? rawCustName : 'Unknown Customer';
    paymentMode = (json['paymentMode'] ?? 'cash').toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['loanId'] = loanId;
    data['amount'] = amount;
    data['rate'] = rate;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['image'] = image;
    data['note'] = note;
    data['updatedAmount'] = updatedAmount;
    data['type'] = type;
    data['userId'] = userId;
    data['custId'] = custId;
    data['custName'] = custName;
    data['paymentMode'] = paymentMode;
    return data;
  }
}