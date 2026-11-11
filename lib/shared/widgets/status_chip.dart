part of pawlink_admin;

class StatusChip extends StatelessWidget {
  final String text;
  final ChipType type;

  const StatusChip({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (type) {
      case ChipType.mutedGreen:
        background = softBeige;
        foreground = forestGreen;
        break;

      case ChipType.success:
        background = successBg;
        foreground = successText;
        break;

      case ChipType.warning:
        background = warningBg;
        foreground = warningText;
        break;

      case ChipType.danger:
        background = dangerBg;
        foreground = dangerText;
        break;

      case ChipType.gray:
        background = grayBg;
        foreground = grayText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: .3,
        ),
      ),
    );
  }
}

const TextStyle sectionLabelStyle =
    TextStyle(
  color: textMuted,
  fontSize: 9,
  fontWeight: FontWeight.w700,
  letterSpacing: .7,
);