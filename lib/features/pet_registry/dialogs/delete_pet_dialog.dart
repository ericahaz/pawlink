part of pawlink_admin;

class DeletePetDialog extends StatelessWidget {
  final PetRecord pet;
  final VoidCallback onChanged;

  const DeletePetDialog({
    super.key,
    required this.pet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: pageBackground,
      title: const Text(
        'Delete Pet Record',
      ),
      content: SizedBox(
        width: 450,
        child: Text(
          pet.deceased
              ? 'Delete ${pet.name} from the current pet registry?'
              : '${pet.name} is still an active pet. '
                  'Mark the pet as deceased before deleting this record.',
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
        if (pet.deceased)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dangerText,
            ),
            onPressed: () {
              pets.remove(pet);

              logActivity(
                'Deleted pet record',
                '${pet.id} • ${pet.name}',
              );

              onChanged();

              Navigator.pop(context);
            },
            child: const Text(
              'Delete Record',
            ),
          ),
      ],
    );
  }
}

