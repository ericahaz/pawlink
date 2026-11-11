part of pawlink_admin;

class CreateInvitationDialog
    extends StatefulWidget {
  final PetRecord pet;
  final VoidCallback onCreated;

  const CreateInvitationDialog({
    super.key,
    required this.pet,
    required this.onCreated,
  });

  @override
  State<CreateInvitationDialog> createState() =>
      _CreateInvitationDialogState();
}

class _CreateInvitationDialogState
    extends State<CreateInvitationDialog> {
  CoOwnerInvitation? created;

  void createInvite() {
    final id =
        'INV-${DateTime.now().millisecondsSinceEpoch}';

    final invite = CoOwnerInvitation(
      id: id,
      petId: widget.pet.id,
      petName: widget.pet.name,
      owner: widget.pet.owner,
      link:
          'https://pawlink.app/invite/$id',
    );

    invitations.insert(0, invite);

    logActivity(
      'Generated co-owner invitation',
      '${widget.pet.name} • $id',
    );

    widget.onCreated();

    setState(() {
      created = invite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: pageBackground,
      title: const Text(
        'Invite a Co-owner',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: softBeige,
                  child: Icon(
                    petIcon(
                      widget.pet.animalType,
                    ),
                    color: forestGreen,
                  ),
                ),
                title: Text(
                  widget.pet.name,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${widget.pet.animalType} • ${widget.pet.breed}\n'
                  'Owner: ${widget.pet.owner}',
                ),
                isThreeLine: true,
              ),
              const Divider(),
              const SizedBox(height: 10),
              if (created == null) ...[
                const Text(
                  'Generate an invitation link and QR code. '
                  'The invited person can use it to request '
                  'co-owner access to this pet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          forestGreen,
                    ),
                    onPressed: createInvite,
                    icon: const Icon(
                      Icons.add_link,
                    ),
                    label: const Text(
                      'Generate Invitation',
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: QrImageView(
                    data: created!.link,
                    size: 190,
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'CO-OWNER INVITATION QR',
                  style: TextStyle(
                    fontSize: 10,
                    color: textMuted,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  created!.link,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: forestGreen,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: created!.link,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.copy,
                  ),
                  label: const Text(
                    'Copy Invitation Link',
                  ),
                ),
              ],
            ],
          ),
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

// ============================================================
// MANAGE CO-OWNER
// ============================================================

