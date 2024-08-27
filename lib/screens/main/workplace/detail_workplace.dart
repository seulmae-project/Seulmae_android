class DetailWorkplace {
  final int workplaceId;
  final String workplaceCode;
  final String workplaceName;
  String? workplaceTel;
  List<String>? workplaceImageUrl; // Change to a list
  String? workplaceManagerName;
  String? workplaceThumbnailUrl;
  final String mainAddress;
  final String subAddress;

  DetailWorkplace({
    required this.workplaceId,
    required this.workplaceCode,
    required this.workplaceName,
    this.workplaceTel,
    this.workplaceImageUrl, // Update constructor
    this.workplaceManagerName,
    this.workplaceThumbnailUrl,
    required this.mainAddress,
    required this.subAddress,
  });

  factory DetailWorkplace.fromJson(Map<String, dynamic> json) {
    // Safely handle different types for workplaceTel
    var workplaceTelValue = json['workplaceTel'];
    String? workplaceTel;

    if (workplaceTelValue is String) {
      workplaceTel = workplaceTelValue;
    } else if (workplaceTelValue is List) {
      workplaceTel = workplaceTelValue.join(', '); // Convert List to a comma-separated string
    }

    // Safely handle the list for workplaceImageUrl
    List<String>? workplaceImageUrl;
    if (json['workplaceImageUrl'] != null && json['workplaceImageUrl'] is List) {
      workplaceImageUrl = List<String>.from(json['workplaceImageUrl']);
    }

    return DetailWorkplace(
      workplaceId: json['workplaceId'] as int,
      workplaceCode: json['workplaceCode'] as String,
      workplaceName: json['workplaceName'] as String,
      workplaceTel: workplaceTel,
      workplaceImageUrl: workplaceImageUrl, // Assign the list
      workplaceManagerName: json['workplaceManagerName'] as String?,
      workplaceThumbnailUrl: json['workplaceThumbnailUrl'] as String?,
      mainAddress: json['mainAddress'] as String,
      subAddress: json['subAddress'] as String,
    );
  }
}
