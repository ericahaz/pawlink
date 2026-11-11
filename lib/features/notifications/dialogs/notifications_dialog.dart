part of pawlink_admin;

class NotificationsDialog extends StatefulWidget {
  final VoidCallback onChanged;

  const NotificationsDialog({
    super.key,
    required this.onChanged,
  });

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  IconData iconFor(AdminNotification n) {
    final value = '${n.title} ${n.message}'.toLowerCase();
    if (value.contains('missing')) return Icons.search_rounded;
    if (value.contains('stray') || value.contains('barangay')) {
      return Icons.pets_outlined;
    }
    if (value.contains('help') || value.contains('message')) {
      return Icons.mark_email_unread_outlined;
    }
    if (value.contains('found')) return Icons.location_on_outlined;
    if (value.contains('qr')) return Icons.qr_code_2;
    return Icons.notifications_active_outlined;
  }

  String destinationName(int index) {
    switch (index) {
      case 7:
        return 'Missing Pets';
      case 8:
        return 'Found Pets';
      case 9:
        return 'Stray Animals';
      case 10:
        return 'Solved Reports';
      case 11:
        return 'QR Registry';
      case 13:
        return 'Activity Log';
      case 15:
        return 'Help Center';
      case 16:
        return 'Barangay Support';
      case 17:
        return 'Support Inbox';
      default:
        return 'PawLink Admin';
    }
  }

  void showNotification(AdminNotification n) {
    setState(() => n.read = true);
    widget.onChanged();

    showDialog(
      context: context,
      builder: (detailsContext) => AlertDialog(
        backgroundColor: pageBackground,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: softBeige,
              child: Icon(iconFor(n), color: forestGreen),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text('Notification Details'),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(detailsContext),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                n.message,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 18),
              DetailLine(
                icon: Icons.schedule_outlined,
                label: 'Received',
                value: formatTime(n.time),
              ),
              DetailLine(
                icon: Icons.open_in_new_outlined,
                label: 'Related Feature',
                value: destinationName(n.pageIndex),
              ),
              const DetailLine(
                icon: Icons.mark_email_read_outlined,
                label: 'Status',
                value: 'Read',
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(detailsContext),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: forestGreen),
            onPressed: () {
              Navigator.pop(detailsContext);
              Navigator.pop(context);
              requestAdminPage(n.pageIndex);
            },
            icon: const Icon(Icons.open_in_new),
            label: Text('Open ${destinationName(n.pageIndex)}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = adminNotifications.where((n) => !n.read).length;

    return AlertDialog(
      backgroundColor: pageBackground,
      title: Row(
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: forestGreen,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  unread == 0
                      ? 'You have no unread notifications.'
                      : 'You have $unread unread notification${unread == 1 ? '' : 's'}. Click one to view it.',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (unread > 0)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  for (final n in adminNotifications) {
                    n.read = true;
                  }
                });
                widget.onChanged();
              },
              icon: const Icon(Icons.done_all, size: 17),
              label: const Text('Mark all read'),
            ),
          IconButton(
            tooltip: 'Close notifications',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 610,
        height: 460,
        child: adminNotifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      color: textMuted,
                      size: 45,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No notifications yet.',
                      style: TextStyle(color: textMuted),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: adminNotifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final n = adminNotifications[i];

                  return Material(
                    color: n.read
                        ? Colors.white
                        : const Color(0xFFF8ECD6),
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () => showNotification(n),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: n.read
                                ? borderColor
                                : const Color(0xFFB8AA8D),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: n.read ? grayBg : softBeige,
                              child: Icon(
                                iconFor(n),
                                color: forestGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: n.read
                                                ? FontWeight.w600
                                                : FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (!n.read)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: mutedGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    n.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: textMuted,
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_outlined,
                                        size: 13,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        formatTime(n.time),
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 9,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.touch_app_outlined,
                                        size: 13,
                                        color: forestGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Click to view details',
                                        style: TextStyle(
                                          color: forestGreen,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: forestGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

