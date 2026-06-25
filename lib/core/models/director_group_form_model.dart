class DirectorGroupFormModel {
  final String? groupNo;
  final String groupName;
  final int? ageMinYr;
  final int? ageMaxYr;

  const DirectorGroupFormModel({
    this.groupNo,
    required this.groupName,
    this.ageMinYr,
    this.ageMaxYr,
  });

  Map<String, dynamic> toJson() {
    return {
      if (groupNo != null) 'groupNo': groupNo,
      'groupNm': groupName.trim(),
      if (ageMinYr != null) 'ageMinYr': ageMinYr,
      if (ageMaxYr != null) 'ageMaxYr': ageMaxYr,
    };
  }
}
