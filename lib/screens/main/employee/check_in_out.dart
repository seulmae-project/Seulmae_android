import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'employee_mock_data.dart';
import 'register_work_screen.dart';

class CheckInOut extends ChangeNotifier {
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Timer? _progressTimer;
  double progress = 0.0;
  int hourlyWage = 0;
  String workplace = '';

  DateTime _workStartTime = DateTime.now();
  DateTime _workEndTime = DateTime.now();

  DateTime get workStartTime => _workStartTime;
  DateTime get workEndTime => _workEndTime;
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  DateTime? get checkOutTime => _checkOutTime;

  void checkIn(BuildContext context) {
    final now = DateTime.now().toUtc().add(Duration(hours: 9));
    final appState = Provider.of<AppState>(context, listen: false);
    final workTime = worktimes.firstWhere(
          (wt) => wt['uid'] == '1' && wt['workplace'] == appState.selectedWorkplace,
      orElse: () => <String, dynamic>{},
    );

    if (workTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('작업 시간이 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _workStartTime = DateTime.parse(workTime['worktime'].split('~')[0]);
    _workEndTime = DateTime.parse(workTime['worktime'].split('~')[1]);
    hourlyWage = workTime['hourlyWage'];  // 시급 정보를 가져옵니다.
    workplace = workTime['workplace'];  // 근무지 정보를 가져옵니다.

    if (now.isBefore(_workStartTime.subtract(Duration(minutes: 10)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('아직 근무 시간이 아닙니다. ${DateFormat('HH:mm').format(_workStartTime)} 10분 전부터 출근할 수 있습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _isCheckedIn = true;
    _checkInTime = now.isAfter(_workStartTime) ? now : _workStartTime;
    progress = 0.0;
    notifyListeners();

    _progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now().toUtc().add(Duration(hours: 9));
      final effectiveStartTime = _checkInTime!.isAfter(_workStartTime) ? _checkInTime! : _workStartTime;

      if (currentTime.isBefore(effectiveStartTime)) {
        progress = 0.0;
      } else if (currentTime.isAfter(_workEndTime)) {
        _progressTimer?.cancel();
        progress = 1.0;
      } else {
        final elapsed = currentTime.difference(effectiveStartTime).inSeconds;
        final total = _workEndTime.difference(effectiveStartTime).inSeconds;
        progress = elapsed / total;
      }

      notifyListeners();
    });
  }

  void checkOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('퇴근'),
          content: Text('정말 퇴근하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                final now = DateTime.now().toUtc().add(Duration(hours: 9));
                _isCheckedIn = false;
                _checkOutTime = now;
                _progressTimer?.cancel();
                progress = 0.0;
                notifyListeners();
                Navigator.of(context).pop();
                _showRegisterWorkDialog(context);
              },
            ),
          ],
        );
      },
    );
  }
  void _showRegisterWorkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('근무 등록'),
          content: Text('근무를 바로 등록하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                print('CheckInTime: $_checkInTime');
                print('CheckOutTime: $_checkOutTime');
                print('HourlyWage: $hourlyWage');
                print('Workplace: $workplace');
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterWorkScreen(
                      checkInTime: _checkInTime,
                      checkOutTime: _checkOutTime,
                      hourlyWage: hourlyWage,
                      workplace: workplace,  // 근무지 정보를 전달합니다.
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

}
