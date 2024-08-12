import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    // 먼저 권한 상태를 확인합니다.
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted) {
      // 권한이 이미 부여된 경우
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // 권한이 부여되지 않은 경우
      await _requestPermission(context, Permission.photos);

      // 권한을 요청한 후 다시 상태를 확인하여 이미지를 선택할 수 있습니다.
      status = await Permission.photos.status;
      if (status.isGranted) {
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          return File(pickedFile.path);
        }
      }
    }

    return null;
  }

  Future<void> _requestPermission(BuildContext context, Permission permission) async {
    // 권한 요청
    final status = await permission.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      _showPermissionDeniedMessage(context);
    }
  }

  void _showPermissionDeniedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('권한이 필요합니다. 설정에서 권한을 허용해주세요.')),
    );
  }
}
