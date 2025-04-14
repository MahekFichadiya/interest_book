class Loandetail {
  Loandetail({
    required this.loanId,
    required this.amount,
    required this.rate,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.note,
    required this.updatedAmount,
    required this.totalDeposite,
    required this.type,
    required this.userId,
    required this.custId,
    required this.interest,
    required this.totalInterest,
     this.lastInterestUpdatedAt,
  });
  late final String loanId;
  late final String amount;
  late final String rate;
  late final String startDate;
  late final String endDate;
  late final String image;
  late final String note;
  late final String updatedAmount;
  late final String totalDeposite;
  late final String type;
  late final String userId;
  late final String custId;
  late final String interest;
  late final String totalInterest;
  late final Null lastInterestUpdatedAt;
  
  Loandetail.fromJson(Map<String, dynamic> json){
    loanId = json['loanId'];
    amount = json['amount'];
    rate = json['rate'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    image = json['image'];
    note = json['note'];
    updatedAmount = json['updatedAmount'];
    totalDeposite = json['totalDeposite'];
    type = json['type'];
    userId = json['userId'];
    custId = json['custId'];
    interest = json['interest'];
    totalInterest = json['totalInterest'];
    lastInterestUpdatedAt = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['loanId'] = loanId;
    _data['amount'] = amount;
    _data['rate'] = rate;
    _data['startDate'] = startDate;
    _data['endDate'] = endDate;
    _data['image'] = image;
    _data['note'] = note;
    _data['updatedAmount'] = updatedAmount;
    _data['totalDeposite'] = totalDeposite;
    _data['type'] = type;
    _data['userId'] = userId;
    _data['custId'] = custId;
    _data['interest'] = interest;
    _data['totalInterest'] = totalInterest;
    _data['lastInterestUpdatedAt'] = lastInterestUpdatedAt;
    return _data;
  }
}