part of pawlink_admin;

class SearchField extends StatelessWidget {
  final String hint;

  const SearchField({
    super.key,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            const Icon(Icons.search),
      ),
    );
  }
}

