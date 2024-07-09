import 'package:flutter/material.dart';
import 'package:sm3/screens/main/workplace/workplace.dart';
import '../employee/employee_dashboard_screen.dart';
import '../main_screen.dart';

// 예시로 사용할 근무지 목록
List<Workplace> workplaces = [
  Workplace(
    name: '근무지 A',
    phoneNumber: '010-1234-5678',
    address: '서울특별시 강남구',
    profileImagePath: 'assets/profile_image_1.png',
  ),
  Workplace(
    name: '근무지 B',
    phoneNumber: '02-9876-5432',
    address: '경기도 성남시 분당구',
    profileImagePath: 'assets/profile_image_1.png',
  ),
  Workplace(
    name: '근무지 C',
    phoneNumber: '031-1111-2222',
    address: '인천광역시 남구',
    profileImagePath: 'assets/profile_image_1.png',
  ),
];

class WorkplaceEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 아이콘 없애기
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[200],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '검색',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: workplaces.length,
        itemBuilder: (context, index) {
          Workplace workplace = workplaces[index];
          return GestureDetector(
            onTap: () {
              _showWorkplaceDetails(context, workplace);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage(workplace.profileImagePath),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workplace.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          workplace.phoneNumber,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          workplace.address,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showWorkplaceDetails(BuildContext context, Workplace workplace) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkplaceDetailsScreen(workplace: workplace),
      ),
    );
  }
}

class WorkplaceDetailsScreen extends StatelessWidget {
  final Workplace workplace;

  const WorkplaceDetailsScreen({Key? key, required this.workplace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workplace.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width, // 화면 너비의 50%
            height: MediaQuery.of(context).size.width, // 화면 너비의 50%
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0), // 사각형 모양을 위한 borderRadius 설정
              image: DecorationImage(
                image: AssetImage(workplace.profileImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 24.0),
          Text(
            '근무지 정보',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          _buildDetailRow('근무지 이름', workplace.name),
          _buildDetailRow('전화번호', workplace.phoneNumber),
          _buildDetailRow('주소', workplace.address),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                    (route) => false, // 이 함수를 통해 모든 이전 route들을 pop하지 않고 false를 리턴하여 남겨둡니다.
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text('참여하기'),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.0),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
