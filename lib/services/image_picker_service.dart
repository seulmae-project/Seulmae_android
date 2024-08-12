import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return await _pickImageFromSource(source);
      } else if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedMessage(context);
      }
    } else {
      // 권한 요청 없이 사진첩에서 이미지를 선택
      return await _pickImageFromSource(source);
    }

    return null;
  }

  Future<File?> _pickImageFromSource(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _showPermissionDeniedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.')),
    );
  }
}
