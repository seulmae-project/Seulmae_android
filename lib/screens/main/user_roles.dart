class User {
  final String id;
  final String name;
  final Map<String, String> roles;

  User({required this.id, required this.name, required this.roles});
}

// Example users
final User testUser = User(
  id: 'test',
  name: 'Test User',
  roles: {
    '근무지 A': 'employee',
    '근무지 B': 'employee',
    '근무지 C': 'employee',
  },
);

final User testUser2 = User(
  id: 'test2',
  name: 'Test User 2',
  roles: {
    '근무지 A': 'manager',
    '근무지 B': 'manager',
    '근무지 C': 'manager',
  },
);
