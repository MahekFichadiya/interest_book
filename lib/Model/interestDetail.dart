class Interestdetail {
  Interestdetail({
    required this.InterestId,
    required this.interestAmount,
    required this.interestDate,
    required this.interestNote,
    required this.loanId,
  });
  late final String InterestId;
  late final String interestAmount;
  late final String interestDate;
  late final String interestNote;
  late final String loanId;
  
  Interestdetail.fromJson(Map<String, dynamic> json){
    InterestId = json['InterestId'];
    interestAmount = json['interestAmount'];
    interestDate = json['interestDate'];
    interestNote = json['interestNote'];
    loanId = json['loanId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['InterestId'] = InterestId;
    _data['interestAmount'] = interestAmount;
    _data['interestDate'] = interestDate;
    _data['interestNote'] = interestNote;
    _data['loanId'] = loanId;
    return _data;
  }
}