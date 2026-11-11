part of pawlink_admin;

class HelpTopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;

  const HelpTopicCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Material(
        color: pageBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: softBeige, child: Icon(icon, color: forestGreen)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, color: forestGreen, size: 19),
                  ],
                ),
                const SizedBox(height: 14),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Text(text, style: const TextStyle(color: textMuted, fontSize: 12, height: 1.45)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================

