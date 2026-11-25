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
    return StreamBuilder<List<PetRecord>>(
      stream: adminDataProvider.petService.getPetsStream(),
      builder: (context, snapshot) {
        final allPets = snapshot.data ?? [];
        final activePets = allPets
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
                onPressed: () async {
                  await adminDataProvider.userService.deleteUser(user.id);

                  adminDataProvider.activityService.logActivity(
                    'Deleted user account',
                    '${user.id} • ${user.name}',
                    currentAdminName,
                  );

                  onDeleted();

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'Delete Account',
                ),
              ),
          ],
        );
      },
    );
  }
}

// ============================================================
// DETAILS DIALOGS
// ============================================================

