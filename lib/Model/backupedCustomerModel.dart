class Backupedcustomermodel {
  Backupedcustomermodel({
    required this.custId,
    required this.custName,
    required this.custPhn,
    required this.custAddress,
    this.custPic,
    required this.date,
  });
  late final String custId;
  late final String custName;
  late final String custPhn;
  late final String custAddress;
  final String? custPic;
  late final String date;
  
  Backupedcustomermodel.fromJson(Map<String, dynamic> json)
      : custPic = json['custPic'] {
    custId = json['custId'];
    custName = json['custName'];
    custPhn = json['custPhn'];
    custAddress = json['custAddress'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['custId'] = custId;
    data['custName'] = custName;
    data['custPhn'] = custPhn;
    data['custAddress'] = custAddress;
    data['custPic'] = custPic;
    data['date'] = date;
    return data;
  }
}