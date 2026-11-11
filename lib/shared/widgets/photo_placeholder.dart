part of pawlink_admin;

class PhotoPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;
  final double width;
  final double height;

  const PhotoPlaceholder({
    super.key,
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: lightCream,
        border:
            Border.all(color: borderColor),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: forestGreen,
            size: 34,
          ),
          const SizedBox(height: 6),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textMuted,
                fontSize: 8,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

