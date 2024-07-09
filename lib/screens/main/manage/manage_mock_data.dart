import 'dart:math';

final List<Map<String, dynamic>> morningShiftData = _generateRandomWorkData(
  [
    {'name': '김철수', 'workplace': '근무지 A', 'role': 'employee', 'uid': '1'},
    {'name': '박영희', 'workplace': '근무지 B', 'role': 'employee', 'uid': '2'},
    {'name': '최민호', 'workplace': '근무지 C', 'role': 'manager', 'uid': '3'},
  ],
  startDate: '2024-06-21',
  endDate: '2024-07-01',
);

final List<Map<String, dynamic>> afternoonShiftData = _generateRandomWorkData(
  [
    {'name': '이민수', 'workplace': '근무지 A', 'role': 'employee'},
    {'name': '최수영', 'workplace': '근무지 B', 'role': 'employee'},
    {'name': '이수민', 'workplace': '근무지 C', 'role': 'manager'},
  ],
  startDate: '2024-06-21',
  endDate: '2024-07-01',
);

List<Map<String, dynamic>> _generateRandomWorkData(
    List<Map<String, String>> employees, {
      required String startDate,
      required String endDate,
    }) {
  final List<Map<String, dynamic>> workData = [];
  final List<String> profileImages = [
    'assets/images/profile_image_1.png',
    'assets/images/profile_image_1.png',
    'assets/images/profile_image_1.png',
    'assets/images/profile_image_1.png',
    'assets/images/profile_image_1.png',
    'assets/images/profile_image_1.png',
  ];

  DateTime start = DateTime.parse(startDate);
  DateTime end = DateTime.parse(endDate);

  for (int i = 0; i < employees.length; i++) {
    List<Map<String, dynamic>> workHistory = [];
    for (DateTime date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(Duration(days: 1))) {
      int startHour = 9 + Random().nextInt(3); // Random start hour between 9 AM and 11 AM
      int endHour = startHour + 8; // End hour after 8 hours of work
      int hourlyWage = 10000 + Random().nextInt(2000); // Random hourly wage between 10000 and 12000
      int wage = (endHour - startHour) * hourlyWage;

      workHistory.add({
        'date': date.toIso8601String().split('T').first,
        'startTime': '${startHour.toString().padLeft(2, '0')}:00',
        'endTime': '${endHour.toString().padLeft(2, '0')}:00',
        'hours': endHour - startHour,
        'wage': wage,
        'description': '무작위 작업 설명',
        'isApproved': Random().nextBool(),
      });
    }

    workData.add({
      'id': (i + 1).toString(),
      'name': employees[i]['name'],
      'profileImage': profileImages[i % profileImages.length],
      'hourlyWage': workHistory[0]['wage'] ~/ workHistory[0]['hours'],
      'workDays': '월, 화, 수',
      'payday': 25,
      'startDate': startDate,
      'endDate': endDate,
      'workHistory': workHistory,
      'workplace': employees[i]['workplace'],
      'role': employees[i]['role'],
    });
  }

  return workData;
}
