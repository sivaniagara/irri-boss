import '../../domain/entities/dealer_customer_entity.dart';

class DealerCustomerModel extends DealerCustomerEntity {
  DealerCustomerModel({
    required super.userName,
    required super.mobileNumber,
    required super.userId,
  });

  factory DealerCustomerModel.fromJson(Map<String, dynamic> json) {
    return DealerCustomerModel(
      userName: json['userName'],
      mobileNumber: json['mobileNumber'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'mobileNumber': mobileNumber,
      'userId': userId,
    };
  }
}
