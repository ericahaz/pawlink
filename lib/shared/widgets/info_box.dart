part of pawlink_admin;

class InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final double width;
  final IconData? icon;

  const InfoBox({
    super.key,
    required this.label,
    required this.value,
    this.width = 125,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: softBeige,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: forestGreen),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: sectionLabelStyle),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

