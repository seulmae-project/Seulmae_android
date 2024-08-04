import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final Function(File?) onImagePicked;
  final ImagePicker _picker = ImagePicker();

  ProfileImagePicker({required this.profileImage, required this.onImagePicked});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File? croppedFile = await _cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        onImagePicked(croppedFile);
      }
    }
  }

  Future<File?> _cropImage(File sourcePath) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: sourcePath.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
    return croppedImage != null ? File(croppedImage.path) : null;
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('사진 촬영'),
              onTap: () async {
                Navigator.of(context).pop();
                await _handleCameraPermission(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('앨범에서 선택'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      if (await Permission.camera.request().isGranted) {
        _pickImage(context, ImageSource.camera);
      } else {
        _showPermissionDeniedDialog(context);
      }
    } else {
      _pickImage(context, ImageSource.camera);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('권한 필요'),
        content: Text('카메라 권한이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: Container(
        width: 160.0,
        height: 320.0,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: profileImage != null
              ? DecorationImage(
            image: FileImage(profileImage!),
            fit: BoxFit.cover,
          )
              : DecorationImage(
            image: AssetImage('assets/profile_image_1.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
