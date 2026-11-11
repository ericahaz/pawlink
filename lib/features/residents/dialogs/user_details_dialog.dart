part of pawlink_admin;

class UserDetailsDialog extends StatelessWidget {
  final PawUser user;

  const UserDetailsDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final owned =
        pets.where((p) => p.owner == user.name).toList();

    return AlertDialog(
      backgroundColor: pageBackground,
      title: Text(user.name),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DetailLine(
              label: 'User ID',
              value: user.id,
            ),
            DetailLine(
              label: 'Account Type',
              value: user.userType,
            ),
            DetailLine(
              label: 'Email',
              value: user.email,
            ),
            DetailLine(
              label: 'Contact',
              value: user.contact,
            ),
            DetailLine(
              label: 'Area',
              value: user.address,
            ),
            DetailLine(
              label: 'Pets',
              value: owned.isEmpty
                  ? 'None'
                  : owned
                      .map(
                        (p) =>
                            '${p.name} (${p.animalType})',
                      )
                      .join(', '),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

