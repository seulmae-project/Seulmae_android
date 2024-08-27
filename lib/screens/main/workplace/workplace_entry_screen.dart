import 'package:flutter/material.dart';
import 'package:sm3/screens/main/workplace/workplace_details_screen.dart';
import 'api_workplace.dart';
import 'detail_workplace.dart';

class WorkplaceEntryScreen extends StatefulWidget {
  @override
  _WorkplaceEntryScreenState createState() => _WorkplaceEntryScreenState();
}

class _WorkplaceEntryScreenState extends State<WorkplaceEntryScreen> {
  Future<List<DetailWorkplace>>? workplaces;
  List<DetailWorkplace>? filteredWorkplaces;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    workplaces = ApiWorkplace.fetchWorkplaces(context);
    workplaces!.then((data) {
      setState(() {
        filteredWorkplaces = data;
      });
    });
  }

  void _filterWorkplaces(String query) async {
    final lowerCaseQuery = query.toLowerCase();
    final allWorkplaces = await workplaces;

    if (allWorkplaces != null) {
      setState(() {
        filteredWorkplaces = allWorkplaces.where((workplace) {
          final workplaceNameLower = workplace.workplaceName.toLowerCase();
          final workplaceAddressLower = (workplace.mainAddress + ' ' + workplace.subAddress).toLowerCase();
          return workplaceNameLower.contains(lowerCaseQuery) ||
              workplaceAddressLower.contains(lowerCaseQuery);
        }).toList();
      });
    }
  }

  void _performSearch() {
    _filterWorkplaces(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 아이콘 없애기
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                    searchQuery = value;
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _performSearch,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<DetailWorkplace>>(
        future: workplaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final workplacesToShow = filteredWorkplaces ?? snapshot.data!;

            return ListView.builder(
              itemCount: workplacesToShow.length,
              itemBuilder: (context, index) {
                DetailWorkplace detailWorkplace = workplacesToShow[index];
                return GestureDetector(
                  onTap: () => _showWorkplaceDetails(context, detailWorkplace),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: detailWorkplace.workplaceThumbnailUrl != null
                              ? NetworkImage(detailWorkplace.workplaceThumbnailUrl!)
                              : AssetImage('assets/profile_image_1.png') as ImageProvider,
                          onBackgroundImageError: (error, stackTrace) {
                            // 에러 발생 시 기본 이미지를 사용할 수 있도록 처리
                            print('Error loading image: $error');
                          },
                        ),

                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detailWorkplace.workplaceName,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 8.0),
                              Text(
                                detailWorkplace.workplaceTel ?? '',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                "${detailWorkplace.mainAddress}, ${detailWorkplace.subAddress}",
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
            );
          }
        },
      ),
    );
  }

  void _showWorkplaceDetails(BuildContext context, DetailWorkplace detailWorkplace) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkplaceDetailsScreen(workplaceId: detailWorkplace.workplaceId),
      ),
    );
  }


}
