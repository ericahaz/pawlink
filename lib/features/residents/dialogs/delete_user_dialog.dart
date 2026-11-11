part of pawlink_admin;

class DeleteUserDialog extends StatelessWidget {
  final PawUser user;
  final VoidCallback onDeleted;

  const DeleteUserDialog({
    super.key,
    required this.user,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final activePets = pets
        .where(
          (p) =>
              p.owner == user.name &&
              !p.deceased,
        )
        .toList();

    return AlertDialog(
      backgroundColor: pageBackground,
      title: const Text(
        'Delete Account',
      ),
      content: SizedBox(
        width: 450,
        child: Text(
          activePets.isNotEmpty
              ? '${user.name} still owns ${activePets.length} active pet(s). '
                  'The account cannot be deleted.'
              : '${user.name} has no active registered pets. '
                  'The account may now be deleted.',
          style: const TextStyle(
            color: textMuted,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (activePets.isEmpty)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dangerText,
            ),
            onPressed: () {
              users.remove(user);

              logActivity(
                'Deleted user account',
                '${user.id} • ${user.name}',
              );

              onDeleted();

              Navigator.pop(context);
            },
            child: const Text(
              'Delete Account',
            ),
          ),
      ],
    );
  }
}

// ============================================================
// DETAILS DIALOGS
// ============================================================

