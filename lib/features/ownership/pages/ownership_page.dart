part of pawlink_admin;

class OwnershipPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const OwnershipPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<OwnershipPage> createState() =>
      _OwnershipPageState();
}

class _OwnershipPageState
    extends State<OwnershipPage> {
  void refresh() {
    setState(() {});
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Owners & Co-owners',
      subtitle:
          'Manage pet ownership and invitation links for shared pet access.',
      child: Column(
        children: [
          for (final pet in pets)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: softBeige,
                        child: Icon(
                          petIcon(
                            pet.animalType,
                          ),
                          color: forestGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              '${pet.name} • ${pet.animalType}',
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Primary Owner: ${pet.owner}',
                              style:
                                  const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Co-owner(s): ${pet.coOwners.isEmpty ? 'None' : pet.coOwners.join(', ')}',
                              style:
                                  const TextStyle(
                                color: textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                ManageCoOwnerDialog(
                              pet: pet,
                              onChanged:
                                  refresh,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.group_add_outlined,
                        ),
                        label:
                            const Text('Manage'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style:
                            FilledButton.styleFrom(
                          backgroundColor:
                              forestGreen,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                CreateInvitationDialog(
                              pet: pet,
                              onCreated:
                                  refresh,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_link,
                        ),
                        label: const Text(
                          'Invite Co-owner',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// INVITATIONS
// ============================================================

