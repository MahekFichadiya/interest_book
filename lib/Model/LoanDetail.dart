class Loandetail {
  Loandetail({
    required this.loanId,
    required this.amount,
    required this.rate,
    required this.startDate,
    required this.endDate,
    required this.note,
    required this.updatedAmount,
    required this.totalDeposite,
    required this.type,
    required this.userId,
    required this.custId,
    required this.interest,
    required this.totalInterest,
    required this.dailyInterest,
    required this.totalDailyInterest,
    required this.paymentMode,
     this.lastInterestUpdatedAt,
  });
  late final String loanId;
  late final String amount;
  late final String rate;
  late final String startDate;
  late final String endDate;
  late final String note;
  late final String updatedAmount;
  late final String totalDeposite;
  late final String type;
  late final String userId;
  late final String custId;
  late final String interest;
  late final String totalInterest;
  late final String dailyInterest;
  late final String totalDailyInterest;
  late final String paymentMode;
  late final Null lastInterestUpdatedAt;
  
  Loandetail.fromJson(Map<String, dynamic> json){
    loanId = json['loanId'];
    amount = json['amount'];
    rate = json['rate'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    note = json['note'];
    updatedAmount = json['updatedAmount'];
    totalDeposite = json['totalDeposite'];
    type = json['type'];
    userId = json['userId'];
    custId = json['custId'];
    interest = json['interest'];
    totalInterest = json['totalInterest'];
    dailyInterest = json['dailyInterest'] ?? '0';
    totalDailyInterest = json['totalDailyInterest'] ?? '0';
    paymentMode = json['paymentMode'] ?? 'cash';
    lastInterestUpdatedAt = null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['loanId'] = loanId;
    data['amount'] = amount;
    data['rate'] = rate;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['note'] = note;
    data['updatedAmount'] = updatedAmount;
    data['totalDeposite'] = totalDeposite;
    data['type'] = type;
    data['userId'] = userId;
    data['custId'] = custId;
    data['interest'] = interest;
    data['totalInterest'] = totalInterest;
    data['dailyInterest'] = dailyInterest;
    data['totalDailyInterest'] = totalDailyInterest;
    data['paymentMode'] = paymentMode;
    data['lastInterestUpdatedAt'] = lastInterestUpdatedAt;
    return data;
  }
}