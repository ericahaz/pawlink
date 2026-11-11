
part of pawlink_admin;

class AdminPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;
  final VoidCallback? onClose;

  const AdminPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageBackground,
      child: Column(
        children: [
          // PAGE TITLE HEADER
          Container(
            width: double.infinity,
            color: pageBackground,
            padding: const EdgeInsets.symmetric(
              horizontal: 34,
              vertical: 21,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                if (action != null) action!,

                if (onClose != null) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: forestGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: borderColor,
          ),

          // PAGE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
