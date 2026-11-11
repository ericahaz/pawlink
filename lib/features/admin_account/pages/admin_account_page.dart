part of pawlink_admin;

class AdminAccountPage extends StatelessWidget {
  const AdminAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPage(
      title: 'Admin Account',
      subtitle:
          'PawLink administrator information and access level.',
      child: AppCard(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: softBeige,
                child: Icon(
                  Icons
                      .admin_panel_settings_outlined,
                  color: forestGreen,
                  size: 35,
                ),
              ),
              SizedBox(width: 18),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Sanchez',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'System Administrator',
                    style: TextStyle(
                      color: textMuted,
                    ),
                  ),
                  SizedBox(height: 5),
                  StatusChip(
                    text: 'ADMIN ACCESS',
                    type: ChipType.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DECEASED / DELETE DIALOGS
// ============================================================

