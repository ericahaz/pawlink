part of pawlink_admin;

class AdminLoginPage extends StatefulWidget {
const AdminLoginPage({super.key});

@override
State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
final homeKey = GlobalKey();
final featuresKey = GlobalKey();
final aboutKey = GlobalKey();
final helpKey = GlobalKey();

void scrollTo(GlobalKey key) {
final context = key.currentContext;
if (context != null) {
Scrollable.ensureVisible(
context,
duration: const Duration(milliseconds: 550),
curve: Curves.easeInOut,
);
}
}

void openAuth({bool create = false}) {
showDialog(
context: context,
barrierDismissible: false,
builder: (_) => AdminAuthDialog(startWithCreate: create),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: pageBackground,
body: Column(
children: [
Container(
height: 72,
padding: const EdgeInsets.symmetric(horizontal: 34),
decoration: const BoxDecoration(
color: pageBackground,
border: Border(bottom: BorderSide(color: borderColor)),
),
child: Row(
children: [
const CircleAvatar(
radius: 19,
backgroundColor: softBeige,
child: Icon(Icons.pets, color: forestGreen, size: 21),
),
const SizedBox(width: 10),
const Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('PawLink', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)),
Text('ADMINISTRATION', style: TextStyle(fontSize: 7, letterSpacing: 1.2, color: textMuted, fontWeight: FontWeight.w700)),
],
),
const Spacer(),
if (MediaQuery.of(context).size.width > 760) ...[
TextButton(onPressed: () => scrollTo(homeKey), child: const Text('Home')),
TextButton(onPressed: () => scrollTo(featuresKey), child: const Text('Features')),
TextButton(onPressed: () => scrollTo(aboutKey), child: const Text('About')),
TextButton(onPressed: () => scrollTo(helpKey), child: const Text('Help')),
const SizedBox(width: 12),
],
OutlinedButton(onPressed: () => openAuth(), child: const Text('Admin Login')),
const SizedBox(width: 8),
FilledButton(
style: FilledButton.styleFrom(backgroundColor: forestGreen),
onPressed: () => openAuth(create: true),
child: const Text('Create Admin Account'),
),
],
),
),
Expanded(
child: SingleChildScrollView(
child: Column(
children: [
Container(
key: homeKey,
width: double.infinity,
color: lightCream,
padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 72),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1180),
child: Row(
children: [
Expanded(
flex: 6,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
decoration: BoxDecoration(color: softBeige, borderRadius: BorderRadius.circular(20)),
child: const Text('PAWLINK ADMIN PORTAL', style: TextStyle(color: forestGreen, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
),
const SizedBox(height: 18),
const Text(
'One place to manage pets,\nreports and your community.',
style: TextStyle(fontSize: 44, height: 1.08, fontWeight: FontWeight.w800, color: textDark),
),
const SizedBox(height: 18),
const Text(
'A clean administration space for PawLink pet records, QR identification, community reports, residents and barangay coordination.',
style: TextStyle(color: textMuted, fontSize: 15, height: 1.6),
),
const SizedBox(height: 26),
Wrap(
spacing: 10,
runSpacing: 10,
children: [
FilledButton.icon(
style: FilledButton.styleFrom(backgroundColor: forestGreen, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
onPressed: () => openAuth(),
icon: const Icon(Icons.login),
label: const Text('Open Admin Portal'),
),
OutlinedButton.icon(
style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
onPressed: () => scrollTo(featuresKey),
icon: const Icon(Icons.arrow_downward),
label: const Text('Explore Features'),
),
],
),
],
),
),
if (MediaQuery.of(context).size.width > 850) ...[
const SizedBox(width: 60),
Expanded(
flex: 4,
child: Container(
height: 330,
padding: const EdgeInsets.all(26),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [mutedGreen, forestGreen]),
borderRadius: BorderRadius.circular(28),
boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12))],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Row(children: [Icon(Icons.admin_panel_settings_outlined, color: Colors.white), SizedBox(width: 8), Text('Administrator workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
const Spacer(),
_LandingMiniCard(icon: Icons.pets_outlined, title: 'Pet Registry', subtitle: 'Profiles, age, breed & status'),
const SizedBox(height: 10),
_LandingMiniCard(icon: Icons.qr_code_2, title: 'QR Identification', subtitle: 'Generated pet QR profiles'),
const SizedBox(height: 10),
_LandingMiniCard(icon: Icons.report_outlined, title: 'Community Reports', subtitle: 'Missing, found & stray cases'),
],
),
),
),
],
],
),
),
),
),
Container(
key: featuresKey,
width: double.infinity,
padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1180),
child: Column(
children: [
const Text('From registration to reunion.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: textDark)),
const SizedBox(height: 8),
const Text('The admin portal keeps PawLink records organized without changing the familiar user-interface style.', style: TextStyle(color: textMuted)),
const SizedBox(height: 28),
Wrap(
spacing: 14,
runSpacing: 14,
alignment: WrapAlignment.center,
children: const [
_LandingFeature(icon: Icons.people_outline, title: 'Residents', text: 'Review resident accounts and their registered pets.'),
_LandingFeature(icon: Icons.pets_outlined, title: 'Pet Registry', text: 'Manage pet information, age, breed, life status and ownership.'),
_LandingFeature(icon: Icons.qr_code_2, title: 'QR Profiles', text: 'View generated QR codes and public scan previews.'),
_LandingFeature(icon: Icons.warning_amber_outlined, title: 'Reports', text: 'Handle missing, found and stray animal reports.'),
],
),
],
),
),
),
),
Container(
key: aboutKey,
width: double.infinity,
color: lightCream,
padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1180),
child: Row(
children: [
const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Useful tools, without the clutter.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: textDark)),
SizedBox(height: 10),
Text('The administration side follows the same simple PawLink experience while giving authorized administrators the controls they need.', style: TextStyle(color: textMuted, height: 1.55)),
],
),
),
const SizedBox(width: 28),
Expanded(
child: Wrap(
spacing: 12,
runSpacing: 12,
children: const [
_SmallInfoTile(icon: Icons.history, text: 'Activity history'),
_SmallInfoTile(icon: Icons.support_agent, text: 'Help Center'),
_SmallInfoTile(icon: Icons.groups_outlined, text: 'Co-owners'),
_SmallInfoTile(icon: Icons.account_balance_outlined, text: 'Barangay support'),
],
),
),
],
),
),
),
),
Container(
key: helpKey,
width: double.infinity,
padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 58),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1180),
child: Container(
padding: const EdgeInsets.all(32),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [mutedGreen, forestGreen]),
borderRadius: BorderRadius.circular(24),
),
child: Row(
children: [
const Icon(Icons.support_agent, size: 50, color: Colors.white),
const SizedBox(width: 22),
const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Need help using PawLink Admin?', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
SizedBox(height: 6),
Text('Sign in and open the interactive Help Center for pet registration, QR, reports, accounts and co-owner guidance.', style: TextStyle(color: Colors.white70, height: 1.45)),
],
),
),
FilledButton(
style: FilledButton.styleFrom(backgroundColor: pageBackground, foregroundColor: forestGreen),
onPressed: () => openAuth(),
child: const Text('Sign In'),
),
],
),
),
),
),
),
const Padding(
padding: EdgeInsets.all(26),
child: Text('PawLink • Community Pet & Stray Management System', style: TextStyle(color: textMuted, fontSize: 11)),
),
],
),
),
),
],
),
);
}
}