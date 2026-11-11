part of pawlink_admin;

class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: textDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

