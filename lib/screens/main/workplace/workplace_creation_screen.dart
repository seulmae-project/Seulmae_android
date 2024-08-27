import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'api_workplace.dart';

class WorkplaceCreationScreen extends StatefulWidget {
  @override
  _WorkplaceCreationScreenState createState() => _WorkplaceCreationScreenState();
}

class _WorkplaceCreationScreenState extends State<WorkplaceCreationScreen> {
  bool _isNextButtonEnabled = false;

  TextEditingController _workplaceNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _zipCodeController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _detailAddressController = TextEditingController();

  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(title: Text('근무지 생성')),
        body: buildBody(context),
        bottomNavigationBar: buildBottomNavigationBar(context),
      ),
    );
  }
  Future<bool> _onBackPressed() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('확인'),
        content: Text('정말로 나가시겠습니까? 변경사항이 저장되지 않을 수 있습니다.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('예'),
          ),
        ],
      ),
    )) ?? false;
  }
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('프로필 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: _showImageSelection,
            child: Container(
              height: MediaQuery.of(context).size.width * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : Icon(Icons.add_photo_alternate, size: 50.0, color: Colors.grey),
            ),
          ),
          SizedBox(height: 16.0),
          buildTextField(_workplaceNameController, '근무지 이름'),
          buildTextField(_phoneNumberController, '전화번호', keyboardType: TextInputType.phone),
          Row(
            children: [
              Expanded(flex: 4, child: buildTextField(_zipCodeController, '우편번호', readOnly: true)),
              SizedBox(width: 8.0),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _openAddressSearch,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('주소 검색', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          buildTextField(_addressController, '주소'),
          buildTextField(_detailAddressController, '상세 주소'),
          SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label + ' 입력',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          keyboardType: keyboardType,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => _checkNextButtonEnabled(),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: _isNextButtonEnabled ? () => _submitForm(context) : null,
        child: Text('다음'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isNextButtonEnabled ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  void _showImageSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('갤러리에서 선택'),
                  onTap: () {
                    _pickImageFromGallery();
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                onTap: () {
                  _takePicture();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _openAddressSearch() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => KpostalView(
                callback: (Kpostal result) {
                  setState(() {
                    _zipCodeController.text = result.postCode;
                    _addressController.text = result.address;
                  });
                  _checkNextButtonEnabled();
                }
            )
        )
    );
  }

  void _submitForm(BuildContext context) async {
    List<File> images = [];
    if (_selectedImage != null) {
      images.add(_selectedImage!); // 선택된 이미지가 있으면 추가
    }
    await ApiWorkplace.createWorkplace(
      context,
      _workplaceNameController.text,
      _addressController.text,
      _detailAddressController.text,
      _phoneNumberController.text,
      images,
    );
  }

  void _checkNextButtonEnabled() {
    setState(() {
      _isNextButtonEnabled = _workplaceNameController.text.isNotEmpty &&
          _phoneNumberController.text.isNotEmpty &&
          _zipCodeController.text.isNotEmpty &&
          _addressController.text.isNotEmpty &&
          _detailAddressController.text.isNotEmpty;
    });
  }
}
