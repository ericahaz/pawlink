part of pawlink_admin;

class SmallReportCard extends StatelessWidget {
  final AnimalReport report;
  final VoidCallback? onTap;

  const SmallReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding:
              const EdgeInsets.all(15),
          leading: CircleAvatar(
            backgroundColor: softBeige,
            child: Icon(
              petIcon(report.animalType),
              color: forestGreen,
            ),
          ),
          title: Text(
            '${report.type} • ${report.petName}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${report.location} • ${report.reporter}',
          ),
          trailing: StatusChip(
            text: report.status.toUpperCase(),
            type: report.status == 'Solved'
                ? ChipType.success
                : ChipType.warning,
          ),
        ),
      ),
    );
  }
}

