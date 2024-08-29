import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import 'check_in_out.dart';
import 'register_work_screen.dart';

class CheckInOutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInOut>(
      builder: (context, checkInOut, child) {
        final now = DateTime.now().toUtc().add(Duration(hours: 9));
        final totalWorkTime = checkInOut.workEndTime.difference(checkInOut.workStartTime).inSeconds;
        final workedTime = now.difference(checkInOut.workStartTime).inSeconds;
        final workedTimePercentage = (workedTime / totalWorkTime * 100).clamp(0, 100).toStringAsFixed(2);

        Color getBackgroundColor() {
          if (checkInOut.workEndTime.difference(now).inMinutes <= 5) {
            return Colors.blue;
          } else {
            return Colors.lightBlue.shade100;
          }
        }
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final selectedWorkplaceId = authProvider.selectedWorkplaceId ?? 0; // Provide a default value if null

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checkInOut.isCheckedIn)
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '근무 시작 시간: ${DateFormat('HH:mm').format(checkInOut.workStartTime)}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          '근무 종료 시간: ${DateFormat('HH:mm').format(checkInOut.workEndTime)}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '현재 진행률: ${workedTimePercentage}%',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    LinearProgressIndicator(value: double.parse(workedTimePercentage) / 100),
                  ],
                ),
              ),
            Padding(

              padding: const EdgeInsets.all(20.0),
              child: checkInOut.isCheckedIn
                  ? ElevatedButton(
                onPressed: () => checkInOut.checkOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: getBackgroundColor(),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('퇴근'),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => checkInOut.checkIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(150, 50),
                    ),
                    child: Text('출근'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterWorkScreen(
                            checkInTime: checkInOut.checkInTime,
                            checkOutTime: checkInOut.checkOutTime,
                            hourlyWage: checkInOut.hourlyWage,
                            workplace: checkInOut.workplace,
                            workplaceId: selectedWorkplaceId, // Convert to int if it's a string                             // Add workplaceId here
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(150, 50),
                    ),
                    child: Text('근무 등록'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
