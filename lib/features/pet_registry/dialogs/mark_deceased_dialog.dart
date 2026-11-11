part of pawlink_admin;

class MarkDeceasedDialog extends StatelessWidget {
  final PetRecord pet;
  final VoidCallback onChanged;

  const MarkDeceasedDialog({
    super.key,
    required this.pet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: pageBackground,
      title: Text(
        'Mark ${pet.name} as deceased?',
      ),
      content: const SizedBox(
        width: 450,
        child: Text(
          'The pet QR profile will become inactive. '
          'The historical record will remain available until '
          'an administrator chooses to delete the pet record.',
          style: TextStyle(
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
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: forestGreen,
          ),
          onPressed: () {
            pet.deceased = true;
            pet.status = 'Deceased';

            logActivity(
              'Marked pet as deceased',
              '${pet.id} • ${pet.name}',
            );

            onChanged();

            Navigator.pop(context);
          },
          child: const Text(
            'Mark Deceased',
          ),
        ),
      ],
    );
  }
}

