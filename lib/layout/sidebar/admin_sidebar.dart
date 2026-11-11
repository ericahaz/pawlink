part of pawlink_admin;

class AdminSidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const AdminSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  Widget section(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        23,
        22,
        23,
        8,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  Widget item(
    int index,
    IconData icon,
    String label,
  ) {
    final active = selected == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: Material(
        color: active ? softBeige : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(
            icon,
            color: active ? forestGreen : textDark,
            size: 21,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: active ? forestGreen : textDark,
              fontSize: 13,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          trailing: active
              ? const CircleAvatar(
                  radius: 3,
                  backgroundColor: forestGreen,
                )
              : null,
          onTap: () => onSelected(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      decoration: const BoxDecoration(
        color: pageBackground,
        border: Border(
          right: BorderSide(color: borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 16,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Material(
              color: pageBackground,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 9,
                        offset: Offset(3, 4),
                      ),
                      BoxShadow(
                        color: Color(0x66FFFFFF),
                        blurRadius: 7,
                        offset: Offset(-3, -3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: forestGreen,
                        child: Icon(
                          Icons.pets,
                          color: pageBackground,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PawLink',
                              style: TextStyle(
                                color: textDark,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'ADMIN PORTAL  •  DASHBOARD',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: forestGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  section('MAIN'),
                  item(
                    0,
                    Icons.home_outlined,
                    'Dashboard',
                  ),
                  section('MANAGEMENT'),
                  item(
                    1,
                    Icons.people_outline,
                    'Residents',
                  ),
                  item(
                    3,
                    Icons.pets_outlined,
                    'Pet Registry',
                  ),
                  item(
                    4,
                    Icons.category_outlined,
                    'Pet Categories',
                  ),
                  item(
                    5,
                    Icons.groups_outlined,
                    'Owners & Co-owners',
                  ),
                  section('REPORTS'),
                  item(
                    6,
                    Icons.description_outlined,
                    'All Reports',
                  ),
                  item(
                    7,
                    Icons.search_outlined,
                    'Missing Pets',
                  ),
                  item(
                    8,
                    Icons.volunteer_activism_outlined,
                    'Found Pets',
                  ),
                  item(
                    9,
                    Icons.warning_amber_outlined,
                    'Stray Animals',
                  ),
                  item(
                    10,
                    Icons.task_alt_outlined,
                    'Solved Reports',
                  ),
                  item(
                    16,
                    Icons.support_agent_outlined,
                    'Barangay Support',
                  ),
                  section('IDENTIFICATION'),
                  item(
                    11,
                    Icons.qr_code_2,
                    'QR Registry',
                  ),
                  item(
                    12,
                    Icons.mark_email_unread_outlined,
                    'Co-owner Invitations',
                  ),
                  section('SYSTEM'),
                  item(
                    13,
                    Icons.history,
                    'Activity Log',
                  ),
                  item(
                    14,
                    Icons.admin_panel_settings_outlined,
                    'Admin Account',
                  ),
                  item(15, Icons.help_outline_rounded, 'Help Center'),
                  item(17, Icons.mark_email_unread_outlined, 'Support Inbox'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: softBeige,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: forestGreen,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Sanchez',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'System Administrator',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      tooltip: 'Logout',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminLoginPage(),
                          ),
                          (_) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

