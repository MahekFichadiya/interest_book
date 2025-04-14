class Backupedcustomermodel {
  Backupedcustomermodel({
    required this.custId,
    required this.custName,
    required this.custPhn,
    required this.custAddress,
    required this.date,
  });
  late final String custId;
  late final String custName;
  late final String custPhn;
  late final String custAddress;
  late final String date;
  
  Backupedcustomermodel.fromJson(Map<String, dynamic> json){
    custId = json['custId'];
    custName = json['custName'];
    custPhn = json['custPhn'];
    custAddress = json['custAddress'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['custId'] = custId;
    _data['custName'] = custName;
    _data['custPhn'] = custPhn;
    _data['custAddress'] = custAddress;
    _data['date'] = date;
    return _data;
  }
}