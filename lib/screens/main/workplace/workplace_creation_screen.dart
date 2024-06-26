import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WorkplaceCreationScreen extends StatefulWidget {
  @override
  _WorkplaceCreationScreenState createState() => _WorkplaceCreationScreenState();
}

class _WorkplaceCreationScreenState extends State<WorkplaceCreationScreen> {
  bool _isNextButtonEnabled = false; // 다음 버튼 활성화 여부

  TextEditingController _workplaceNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _zipCodeController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _detailAddressController = TextEditingController();

  File? _selectedImage; // 선택된 이미지를 저장할 변수

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('경고'),
            content: Text('정말 나가시겠습니까? 입력한 정보는 저장되지 않습니다.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('예'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // 글자색
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('아니오'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red, // 글자색
                ),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('근무지 생성 화면'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '프로필 이미지',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => _pickImageFromGallery(),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.5, // 이미지 영역 세로로 30% 늘리기
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.add_photo_alternate,
                    size: 50.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              const Text(
                '근무지 이름',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _workplaceNameController,
                decoration: InputDecoration(
                  hintText: '근무지 이름을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (_) => _checkNextButtonEnabled(),
              ),
              SizedBox(height: 16.0),
              const Text(
                '근무지 전화번호',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  hintText: '전화번호를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  counterText: '', // 글자 수 제한 표시 제거
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                onChanged: (_) => _checkNextButtonEnabled(),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _zipCodeController,
                      decoration: InputDecoration(
                        hintText: '우편번호',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        counterText: '', // 글자 수 제한 표시 제거
                      ),
                      maxLength: 5,
                      onChanged: (_) => _checkNextButtonEnabled(),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 60.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement address search functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // 버튼 배경색
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          '주소 검색',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              const Text(
                '주소',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: '주소를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (_) => _checkNextButtonEnabled(),
              ),
              SizedBox(height: 16.0),
              const Text(
                '상세 주소',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _detailAddressController,
                decoration: InputDecoration(
                  hintText: '상세 주소를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (_) => _checkNextButtonEnabled(),
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isNextButtonEnabled
                  ? () {
                // Navigate to next screen or perform desired action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerificationCheckScreen(
                      verificationCodeControllers: _getVerificationCodeControllers(),
                    ),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNextButtonEnabled ? Colors.lightBlue : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ),
      ),
    );
  }

  // Function to check if the next button should be enabled
  void _checkNextButtonEnabled() {
    bool isEnabled = _workplaceNameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _zipCodeController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _selectedImage != null; // 이미지가 선택되었는지 확인 추가
    setState(() {
      _isNextButtonEnabled = isEnabled;
    });
  }

  // Function to pick image from gallery
  void _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to get verification code controllers
  List<TextEditingController> _getVerificationCodeControllers() {
    // Define your logic to get controllers
    return [];
  }
}

class PhoneVerificationCheckScreen extends StatelessWidget {
  final List<TextEditingController> verificationCodeControllers;

  const PhoneVerificationCheckScreen({
    Key? key,
    required this.verificationCodeControllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build your phone verification check screen UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Verification Check'),
      ),
      body: Center(
        child: Text('Phone Verification Check Screen'),
      ),
    );
  }
}
