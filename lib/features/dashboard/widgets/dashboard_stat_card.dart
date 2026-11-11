part of pawlink_admin;

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double width;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.width = 225,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: softBeige,
                child: Icon(icon, color: forestGreen, size: 22),
              ),
              const SizedBox(height: 18),
              Text(
                value,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}