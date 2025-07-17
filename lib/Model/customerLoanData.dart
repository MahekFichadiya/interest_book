class Customerloandata {
  Customerloandata({
    required this.custName,
    required this.date,
    required this.youGaveAmount,
    required this.youGotAmount,
    required this.youGaveInterest,
    required this.youGotInterest,
    required this.totalYouGave,
    required this.totalYouGot,
    required this.balance,
  });
  late final String custName;
  late final String date;
  late final String youGaveAmount;
  late final String youGotAmount;
  late final String youGaveInterest;
  late final String youGotInterest;
  late final String totalYouGave;
  late final String totalYouGot;
  late final String balance;

  Customerloandata.fromJson(Map<String, dynamic> json){
    custName = json['custName'] ?? '';
    date = json['date'] ?? '';
    youGaveAmount = (json['you_gave_amount'] ?? 0).toString();
    youGotAmount = (json['you_got_amount'] ?? 0).toString();
    youGaveInterest = (json['you_gave_interest'] ?? 0).toString();
    youGotInterest = (json['you_got_interest'] ?? 0).toString();
    totalYouGave = (json['total_you_gave'] ?? 0).toString();
    totalYouGot = (json['total_you_got'] ?? 0).toString();
    balance = (json['balance'] ?? 0).toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['custName'] = custName;
    data['date'] = date;
    data['you_gave_amount'] = youGaveAmount;
    data['you_got_amount'] = youGotAmount;
    data['you_gave_interest'] = youGaveInterest;
    data['you_got_interest'] = youGotInterest;
    data['total_you_gave'] = totalYouGave;
    data['total_you_got'] = totalYouGot;
    data['balance'] = balance;
    return data;
  }
}