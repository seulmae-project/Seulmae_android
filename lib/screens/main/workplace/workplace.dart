// workplace.dart
class Workplace {
  final String name;
  final String phoneNumber;
  final String address;
  final String profileImagePath;

  Workplace({
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.profileImagePath
  });
  factory Workplace.fromJson(Map<String, dynamic> json) {
    return Workplace(
      name: json['workplaceName'],
      phoneNumber: json['workplaceName'],
      address: json['address'],
      profileImagePath: json['workplaceName'],
    );
  }
}