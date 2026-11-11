part of pawlink_admin;

class EmptyCard extends StatelessWidget {
  final String text;

  const EmptyCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

enum ChipType {
  mutedGreen,
  success,
  warning,
  danger,
  gray,
}

