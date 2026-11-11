part of pawlink_admin;

class ManageCoOwnerDialog
    extends StatefulWidget {
  final PetRecord pet;
  final VoidCallback onChanged;

  const ManageCoOwnerDialog({
    super.key,
    required this.pet,
    required this.onChanged,
  });

  @override
  State<ManageCoOwnerDialog> createState() =>
      _ManageCoOwnerDialogState();
}

class _ManageCoOwnerDialogState
    extends State<ManageCoOwnerDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: pageBackground,
      title: Text(
        'Co-owners — ${widget.pet.name}',
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const FormLabel(
              'Primary Owner',
            ),
            Text(widget.pet.owner),
            const SizedBox(height: 18),
            const FormLabel(
              'Current Co-owners',
            ),
            if (widget.pet.coOwners.isEmpty)
              const Text(
                'No co-owner assigned.',
                style: TextStyle(
                  color: textMuted,
                ),
              ),
            for (final coOwner
                in widget.pet.coOwners)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.person_outline,
                ),
                title: Text(coOwner),
                trailing: IconButton(
                  tooltip: 'Remove',
                  onPressed: () {
                    setState(() {
                      widget.pet.coOwners
                          .remove(coOwner);
                    });

                    logActivity(
                      'Removed pet co-owner',
                      '$coOwner • ${widget.pet.name}',
                    );

                    widget.onChanged();
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ),
            const SizedBox(height: 15),
            const FormLabel(
              'Add Co-owner',
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText:
                    'Enter registered user name',
              ),
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
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: forestGreen,
          ),
          onPressed: () {
            final name =
                controller.text.trim();

            if (name.isNotEmpty &&
                !widget.pet.coOwners
                    .contains(name)) {
              widget.pet.coOwners.add(name);

              logActivity(
                'Added pet co-owner',
                '$name • ${widget.pet.name}',
              );

              widget.onChanged();
            }

            Navigator.pop(context);
          },
          child: const Text(
            'Add Co-owner',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// REPORTS
// ============================================================

