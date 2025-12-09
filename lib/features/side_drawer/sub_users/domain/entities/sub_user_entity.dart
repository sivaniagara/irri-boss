class SubUserEntity {
  final dynamic sharedUserId;
  final dynamic subuserId;
  final String userName;
  final String mobileNumber;
  final String mobileCountryCode;
  final String subUserCode;

  SubUserEntity({
    required this.userName,
    required this.subuserId,
    required this.mobileCountryCode,
    required this.mobileNumber,
    required this.sharedUserId,
    required this.subUserCode
  });

  SubUserEntity copyWith({
    int? sharedUserId,
    String? subUserCode,
    String? userName,
    String? mobileNumber,
    String? mobileCountryCode,
    int? subuserId,
  }) {
    return SubUserEntity(
      sharedUserId: sharedUserId ?? this.sharedUserId,
      subUserCode: subUserCode ?? this.subUserCode,
      userName: userName ?? this.userName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mobileCountryCode: mobileCountryCode ?? this.mobileNumber,
      subuserId: subuserId ?? this.subuserId,
    );
  }
}