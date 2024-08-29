

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoticeSection extends StatelessWidget {
  final PageController pageController;
  final int currentNoticePage;
  final List<String> notices;
  final Function(int) onPageChanged;

  NoticeSection({
    required this.pageController,
    required this.currentNoticePage,
    required this.notices,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 2.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  notices.length,
                      (index) => GestureDetector(
                    onTap: () {
                      pageController.jumpToPage(index);
                      onPageChanged(index);
                    },
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentNoticePage == index
                            ? Colors.grey
                            : Colors.black12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50.0,
              child: PageView.builder(
                controller: pageController,
                itemCount: notices.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      notices[index],
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
