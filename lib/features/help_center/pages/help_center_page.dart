part of pawlink_admin;

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminPage(
      title: 'Help Center',
      subtitle: 'Open guides, FAQs and administrator support tools.',
      child: HelpCenterContent(),
    );
  }
}

