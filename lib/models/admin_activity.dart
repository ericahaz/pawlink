part of pawlink_admin;

class AdminActivity {
  final String action;
  final String target;
  final DateTime time;

  AdminActivity({
    required this.action,
    required this.target,
    required this.time,
  });
}

