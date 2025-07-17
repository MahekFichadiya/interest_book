class Interestdetail {
  Interestdetail({
    required this.InterestId,
    required this.interestAmount,
    required this.interestDate,
    required this.interestNote,
    required this.loanId,
    this.interestField,
  });
  late final String InterestId;
  late final String interestAmount;
  late final String interestDate;
  late final String interestNote;
  late final String loanId;
  late final String? interestField;
  
  Interestdetail.fromJson(Map<String, dynamic> json){
    InterestId = json['InterestId'];
    interestAmount = json['interestAmount'];
    interestDate = json['interestDate'];
    interestNote = json['interestNote'];
    loanId = json['loanId'];
    interestField = json['interestField'] ?? 'cash';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['InterestId'] = InterestId;
    data['interestAmount'] = interestAmount;
    data['interestDate'] = interestDate;
    data['interestNote'] = interestNote;
    data['loanId'] = loanId;
    data['interestField'] = interestField;
    return data;
  }
}