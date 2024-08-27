class UserWorkplaceInfo {
  int workplaceId;
  String workplaceName;
  Address address;
  String? workplaceTel; // Nullable
  String? managerName;  // Nullable
  bool isManager;

  UserWorkplaceInfo({
    required this.workplaceId,
    required this.workplaceName,
    required this.address,
    this.workplaceTel,
    this.managerName,
    required this.isManager,
  });

  factory UserWorkplaceInfo.fromJson(Map<String, dynamic> json) {
    return UserWorkplaceInfo(
      workplaceId: json['workplaceId'],
      workplaceName: json['workplaceName'],
      address: Address.fromJson(json['address']),
      workplaceTel: json['workplaceTel'] as String?, // Handle nullability
      managerName: json['managerName'] as String?,  // Handle nullability
      isManager: json['isManager'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workplaceId': workplaceId,
      'workplaceName': workplaceName,
      'address': address.toJson(),
      'workplaceTel': workplaceTel, // Can be null
      'managerName': managerName,   // Can be null
      'isManager': isManager,
    };
  }

  @override
  String toString() {
    return 'UserWorkplaceInfo(workplaceId: $workplaceId, workplaceName: $workplaceName, workplaceTel: $workplaceTel, managerName: $managerName, isManager: $isManager)';
  }
}



class Address {
  // Define the properties based on your AddressVo structure in Java
  String mainAddress;
  String subAddress;

  Address({
    required this.mainAddress,
    required this.subAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      mainAddress: json['mainAddress'],
      subAddress: json['subAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainAddress': mainAddress,
      'subAddress': subAddress,
    };
  }
}
