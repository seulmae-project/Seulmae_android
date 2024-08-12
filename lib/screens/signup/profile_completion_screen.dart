import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:sm3/screens/signup/signup_completion_screen.dart';
import '../../config.dart';
import 'sign_up_data.dart'; // SignUpData 클래스 파일을 import하세요.
import 'package:sm3/services/image_picker_service.dart'; // ImagePickerService 파일을 import하세요.
import 'package:http_parser/http_parser.dart';  // MediaType 클래스를 사용하기 위한 import

class ProfileCompletionScreen extends StatefulWidget {
  final SignUpData signUpData;

  const ProfileCompletionScreen({
    Key? key,
    required this.signUpData,
  }) : super(key: key);

  @override
  _ProfileCompletionScreenState createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  String _selectedGender = '여성'; // Default gender
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime(1990, 10, 10); // Default date
  File? _selectedImage;

  final ImagePickerService _imagePickerService = ImagePickerService();

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
          _selectedGender.isNotEmpty &&
          _selectedDate != null;

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("프로필 이미지 설정"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('갤러리에서 선택'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    File? image = await _imagePickerService.pickImage(
                      context: context,
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('카메라로 촬영'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    File? image = await _imagePickerService.pickImage(
                      context: context,
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('기본 이미지로 설정'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedImage = null;  // 기본 이미지로 설정
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSignUp() async {
    final updatedSignUpData = widget.signUpData.copyWith(
      name: _nameController.text,
      isMale: _selectedGender == '남성',
      birthday: "${_selectedDate.year}${_selectedDate.month.toString().padLeft(2, '0')}${_selectedDate.day.toString().padLeft(2, '0')}",
    );

    final url = Uri.parse('${Config.baseUrl}/api/users');
    var request = http.MultipartRequest('POST', url);

    // Add the JSON data as a separate multipart field with content type `application/json`
    request.files.add(
      http.MultipartFile.fromString(
        'userSignUpDto',
        json.encode({
          'accountId': updatedSignUpData.accountId,
          'password': updatedSignUpData.password,
          'phoneNumber': updatedSignUpData.phoneNumber,
          'name': updatedSignUpData.name,
          'isMale': updatedSignUpData.isMale,
          'birthday': updatedSignUpData.birthday,
        }),
        contentType: MediaType('application', 'json'),
      ),
    );

    if (_selectedImage != null) {
      String mimeType = _selectedImage!.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        print("mimeType");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpCompletionScreen(name: updatedSignUpData.name)),
        );
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [], // Removed notification icon
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft, // Aligns the text to the left
              child: Text(
                '프로필을\n완성해 주세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60, // Increased size for better visibility
                      backgroundColor: Colors.grey.shade300, // Softer color for modern look
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null ? Icon(Icons.person_add, size: 60, color: Colors.grey.shade600) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        height: 34, // Increased size for better touch area
                        width: 34,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent, // Bright color for visibility
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.white),
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20.0),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('남성'),
                    leading: Radio<String>(
                      value: '남성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('여성'),
                    leading: Radio<String>(
                      value: '여성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름 입력',
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDate.year,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDate = DateTime(newValue!, _selectedDate.month, _selectedDate.day);
                      });
                    },
                    items: List.generate(
                      100,
                          (index) => DropdownMenuItem(
                        value: 1920 + index,
                        child: Text('${1920 + index}'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDate.month,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, newValue!, _selectedDate.day);
                      });
                    },
                    items: List.generate(
                      12,
                          (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDate.day,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, newValue!);
                      });
                    },
                    items: List.generate(
                      31,
                          (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isFormValid ? _handleSignUp : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid ? Color(0xFF4A90E2) : Colors.grey.shade300,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            minimumSize: Size.fromHeight(50), // To match the image button size
          ),
          child: const Text(
            '가입 완료',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
