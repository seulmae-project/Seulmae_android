import 'dart:typed_data'; // Uint8List import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmfao3/screens/main/workplace/workplace_details_screen.dart';
import 'api_workplace.dart';
import 'detail_workplace.dart';
import '../../../providers/auth_provider.dart';

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

  Future<ImageProvider> _getImageProvider(String? url) async {
    if (url == null) {
      return AssetImage('assets/profile_image_1.png') as ImageProvider;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final imageBytes = await ApiWorkplace.fetchImageWithAuth(url, authProvider.accessToken);
    if (imageBytes != null) {
      return MemoryImage(imageBytes);
    } else {
      return AssetImage('assets/profile_image_1.png') as ImageProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: false,
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
    FutureBuilder<ImageProvider>(
    future: _getImageProvider(detailWorkplace.workplaceThumbnailUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage('assets/profile_image_1.png'),
          );
        } else if (snapshot.hasError) {
          return CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage('assets/profile_image_1.png'),
          );
        } else {
          return CircleAvatar(
            radius: 30.0,
            backgroundImage: snapshot.data!,
          );
        }
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

