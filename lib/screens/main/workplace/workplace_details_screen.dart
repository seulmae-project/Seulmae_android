import 'dart:typed_data';  // 이 라인을 유지하여 올바른 Uint8List를 사용합니다.
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../providers/auth_provider.dart';
import 'api_workplace.dart';
import 'detail_workplace.dart';

class WorkplaceDetailsScreen extends StatefulWidget {
  final int workplaceId;

  const WorkplaceDetailsScreen({Key? key, required this.workplaceId}) : super(key: key);

  @override
  _WorkplaceDetailsScreenState createState() => _WorkplaceDetailsScreenState();
}

class _WorkplaceDetailsScreenState extends State<WorkplaceDetailsScreen> {
  Future<DetailWorkplace>? workplaceDetails;

  @override
  void initState() {
    super.initState();
    workplaceDetails = ApiWorkplace.fetchWorkplaceDetails(context, widget.workplaceId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DetailWorkplace>(
          future: workplaceDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error');
            } else if (snapshot.hasData && snapshot.data != null) {
              return Text(snapshot.data!.workplaceName ?? '');
            } else {
              return Text('No Data');
            }
          },
        ),
      ),
      body: FutureBuilder<DetailWorkplace>(
        future: workplaceDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data != null) {
            final detailWorkplace = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.infinity,
                        child: (detailWorkplace.workplaceImageUrl != null &&
                            detailWorkplace.workplaceImageUrl!.isNotEmpty)
                            ? FutureBuilder<Uint8List?>(
                          future: ApiWorkplace.fetchImageWithAuth(
                              detailWorkplace.workplaceImageUrl![0], authProvider.accessToken),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return Container(
                                child: Center(child: Text('Failed to load image')),
                              );
                            } else {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        )
                            : Container(
                          child: Center(
                            child: Image.asset(
                            'assets/profile_image_1.png',
                            fit: BoxFit.cover,
                          ),),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detailWorkplace.workplaceName ?? 'No Name Available',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.blueGrey),
                            SizedBox(width: 8.0),
                            Text(
                              detailWorkplace.workplaceTel ?? 'No Contact Information',
                              style: TextStyle(fontSize: 18.0, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blueGrey),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                "${detailWorkplace.mainAddress ?? 'No Address Available'}, ${detailWorkplace.subAddress ?? ''}",
                                style: TextStyle(fontSize: 18.0, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("No data found"));
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<DetailWorkplace>(
        future: workplaceDetails,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {
                  ApiWorkplace.joinWorkplace(context, snapshot.data!.workplaceId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18.0),
                ),
                child: Text('참여하기'),
              ),
            );
          } else {
            return SizedBox.shrink(); // 데이터가 없을 때 버튼을 숨깁니다.
          }
        },
      ),
    );
  }
}
