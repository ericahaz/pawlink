part of pawlink_admin;

class HelpCenterStandalonePage extends StatelessWidget {
  const HelpCenterStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.white,
        foregroundColor: textDark,
        title: const Row(
          children: [
            Icon(Icons.pets, color: forestGreen),
            SizedBox(width: 10),
            Text('PawLink Help Center'),
          ],
        ),
      ),
      body: const HelpCenterContent(),
    );
  }
}

