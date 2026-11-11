part of pawlink_admin;

class CategoryCard extends StatelessWidget {
  final double width;
  final String title;
  final String category;
  final int count;
  final IconData icon;
  final String description;

  const CategoryCard({
    super.key,
    required this.width,
    required this.title,
    required this.category,
    required this.count,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 225,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetailsPage(
                  title: title,
                  category: category,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 13,
                  offset: Offset(5, 7),
                ),
                BoxShadow(
                  color: Color(0x70FFFFFF),
                  blurRadius: 10,
                  offset: Offset(-4, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: forestGreen,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(icon, color: lightCream, size: 27),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'pet' : 'pets'}',
                        style: const TextStyle(
                          color: forestGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 13),
                const Row(
                  children: [
                    Text(
                      'VIEW CATEGORY',
                      style: TextStyle(
                        color: forestGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: forestGreen,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

