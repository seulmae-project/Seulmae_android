import 'package:flutter/material.dart';

class DetailInfoWorkplace {
  final int workplaceId;
  final String workplaceCode;
  final String workplaceName;
  String? workplaceTel;
  List<String>? workplaceImageUrl;
  final String mainAddress;
  final String subAddress;

  DetailInfoWorkplace({
    required this.workplaceId,
    required this.workplaceCode,
    required this.workplaceName,
    this.workplaceTel,
    this.workplaceImageUrl,
    required this.mainAddress,
    required this.subAddress,
  });

  factory DetailInfoWorkplace.fromJson(Map<String, dynamic> json) {
    List<String>? workplaceImageUrl;
    if (json['workplaceImageUrlList'] != null && json['workplaceImageUrlList'] is List) {
      workplaceImageUrl = List<String>.from(json['workplaceImageUrlList']);
    }

    return DetailInfoWorkplace(
      workplaceId: json['workplaceId'] as int,
      workplaceCode: json['workplaceCode'] as String,
      workplaceName: json['workplaceName'] as String,
      workplaceTel: json['workplaceTel'] as String?,
      workplaceImageUrl: workplaceImageUrl,
      mainAddress: json['mainAddress'] as String,
      subAddress: json['subAddress'] as String,
    );
  }
}
