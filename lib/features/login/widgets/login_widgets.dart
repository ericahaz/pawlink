part of pawlink_admin;

class _LandingMiniCard extends StatelessWidget {
final IconData icon; final String title; final String subtitle;
const _LandingMiniCard({required this.icon, required this.title, required this.subtitle});
@override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: lightCream.withAlpha(242), borderRadius: BorderRadius.circular(14)), child: Row(children: [CircleAvatar(backgroundColor: softBeige, child: Icon(icon, color: forestGreen, size: 19)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: textDark)), Text(subtitle, style: const TextStyle(fontSize: 9.5, color: textMuted))]))]));
}

class _LandingFeature extends StatelessWidget {
final IconData icon; final String title; final String text;
const _LandingFeature({required this.icon, required this.title, required this.text});
@override Widget build(BuildContext context) => SizedBox(width: 265, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: borderColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(backgroundColor: softBeige, child: Icon(icon, color: forestGreen)), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(text, style: const TextStyle(color: textMuted, fontSize: 11.5, height: 1.45))])));
}

class _SmallInfoTile extends StatelessWidget {
final IconData icon; final String text;
const _SmallInfoTile({required this.icon, required this.text});
@override Widget build(BuildContext context) => Container(width: 190, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)), child: Row(children: [Icon(icon, color: forestGreen), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5)))]));
}

class _AuthFeature extends StatelessWidget {
final IconData icon; final String text;
const _AuthFeature({required this.icon, required this.text});
@override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 9), Text(text, style: const TextStyle(color: Colors.white, fontSize: 11.5))]));
}