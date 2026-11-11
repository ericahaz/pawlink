part of pawlink_admin;

class CompareReportDialog extends StatefulWidget {
  final AnimalReport found;
  final VoidCallback onChanged;

  const CompareReportDialog({
    super.key,
    required this.found,
    required this.onChanged,
  });

  @override
  State<CompareReportDialog> createState() =>
      _CompareReportDialogState();
}

class _CompareReportDialogState
    extends State<CompareReportDialog> {
  AnimalReport? selectedMissing;

  @override
  Widget build(BuildContext context) {
    final missing = reports
        .where(
          (r) =>
              r.type == 'Missing' &&
              r.status == 'Pending',
        )
        .toList();

    selectedMissing ??=
        missing.isEmpty ? null : missing.first;

    return AlertDialog(
      backgroundColor: pageBackground,
      title: const Text(
        'Compare Found & Missing Pet',
      ),
      content: SizedBox(
        width: 900,
        child: missing.isEmpty
            ? const Text(
                'There are no pending missing-pet reports.',
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<
                        AnimalReport>(
                      initialValue:
                          selectedMissing,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Missing pet report',
                      ),
                      items: [
                        for (final report
                            in missing)
                          DropdownMenuItem(
                            value: report,
                            child: Text(
                              '${report.petName} • ${report.id}',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedMissing =
                              value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              CompareColumn(
                            title:
                                'MISSING PET',
                            report:
                                selectedMissing!,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child:
                              CompareColumn(
                            title:
                                'FOUND PET',
                            report:
                                widget.found,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            logActivity(
              'Rejected possible pet match',
              widget.found.id,
            );

            Navigator.pop(context);
          },
          child: const Text(
            'Not a Match',
          ),
        ),
        if (selectedMissing != null)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: forestGreen,
            ),
            onPressed: () {
              selectedMissing!.status =
                  'Solved';
              widget.found.status =
                  'Solved';

              final linkedPet =
                  pets.where(
                (p) =>
                    p.id ==
                    selectedMissing!.petId,
              );

              if (linkedPet.isNotEmpty) {
                linkedPet.first.status =
                    'Active';
              }

              logActivity(
                'Confirmed found/missing pet match',
                '${selectedMissing!.id} ↔ ${widget.found.id}',
              );

              widget.onChanged();

              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.check,
            ),
            label: const Text(
              'Confirm Match',
            ),
          ),
      ],
    );
  }
}

