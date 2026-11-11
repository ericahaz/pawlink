part of pawlink_admin;

class InvitationsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const InvitationsPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<InvitationsPage> createState() =>
      _InvitationsPageState();
}

class _InvitationsPageState
    extends State<InvitationsPage> {
  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Co-owner Invitations',
      subtitle:
          'View invitation links and QR codes generated for pet co-owners.',
      child: invitations.isEmpty
          ? const EmptyCard(
              text:
                  'No co-owner invitations have been generated yet.',
            )
          : Column(
              children: [
                for (final invitation
                    in invitations)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: AppCard(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          18,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding:
                                  const EdgeInsets
                                      .all(7),
                              decoration:
                                  BoxDecoration(
                                border:
                                    Border.all(
                                  color:
                                      borderColor,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),
                              child: QrImageView(
                                data: invitation
                                    .link,
                              ),
                            ),
                            const SizedBox(
                                width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    invitation
                                        .petName,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Owner: ${invitation.owner}',
                                    style:
                                        const TextStyle(
                                      color:
                                          textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5),
                                  SelectableText(
                                    invitation
                                        .link,
                                    style:
                                        const TextStyle(
                                      color:
                                          forestGreen,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              text: invitation
                                  .status
                                  .toUpperCase(),
                              type: invitation
                                          .status ==
                                      'Accepted'
                                  ? ChipType
                                      .success
                                  : ChipType
                                      .warning,
                            ),
                            const SizedBox(
                                width: 10),
                            OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        invitation
                                            .link,
                                  ),
                                );

                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Invitation link copied.',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 17,
                              ),
                              label: const Text(
                                'Copy',
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

