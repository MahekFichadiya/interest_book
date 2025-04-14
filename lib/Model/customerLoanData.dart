class Customerloandata {
  Customerloandata({
    required this.custName,
    required this.date,
    required this.youGaveAmount,
    required this.youGotAmount,
  });
  late final String custName;
  late final String date;
  late final String youGaveAmount;
  late final String youGotAmount;
  
  Customerloandata.fromJson(Map<String, dynamic> json){
    custName = json['custName'];
    date = json['date'];
    youGaveAmount = json['you_gave_amount'];
    youGotAmount = json['you_got_amount'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['custName'] = custName;
    _data['date'] = date;
    _data['you_gave_amount'] = youGaveAmount;
    _data['you_got_amount'] = youGotAmount;
    return _data;
  }
}