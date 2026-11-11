part of pawlink_admin;

class AdminAuthDialog extends StatefulWidget {
final bool startWithCreate;
const AdminAuthDialog({super.key, this.startWithCreate = false});

@override
State<AdminAuthDialog> createState() => _AdminAuthDialogState();
}

class _AdminAuthDialogState extends State<AdminAuthDialog> {
late bool createMode;
bool hidePassword = true;
bool agreement = false;
final nameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();

@override
void initState() {
super.initState();
createMode = widget.startWithCreate;
}

void continueToAdmin() {
if (!agreement) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept the privacy and responsible-use agreement first.')));
return;
}
if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty || (createMode && nameController.text.trim().isEmpty)) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete the required fields.')));
return;
}
logActivity(createMode ? 'Administrator account created (prototype)' : 'Administrator signed in', emailController.text.trim());
Navigator.pop(context);
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
}

@override
Widget build(BuildContext context) {
return Dialog(
backgroundColor: Colors.transparent,
insetPadding: const EdgeInsets.all(24),
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 900),
child: Container(
decoration: BoxDecoration(color: lightCream, borderRadius: BorderRadius.circular(24)),
clipBehavior: Clip.antiAlias,
child: Row(
children: [
if (MediaQuery.of(context).size.width > 760)
Expanded(
child: Container(
constraints: const BoxConstraints(minHeight: 590),
padding: const EdgeInsets.all(38),
decoration: const BoxDecoration(gradient: LinearGradient(colors: [mutedGreen, forestGreen], begin: Alignment.topLeft, end: Alignment.bottomRight)),
child: const Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(children: [Icon(Icons.pets, color: Colors.white, size: 30), SizedBox(width: 10), Text('PawLink', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))]),
Spacer(),
Text('Your pets,\nyour community,\nconnected.', style: TextStyle(color: Colors.white, fontSize: 34, height: 1.08, fontWeight: FontWeight.w800)),
SizedBox(height: 14),
Text('Administrative access for managing pet profiles, reports, QR identification and community records.', style: TextStyle(color: Colors.white70, height: 1.5)),
SizedBox(height: 22),
_AuthFeature(icon: Icons.pets_outlined, text: 'Pet records and life status'),
_AuthFeature(icon: Icons.qr_code_2, text: 'QR identification registry'),
_AuthFeature(icon: Icons.report_outlined, text: 'Community report management'),
_AuthFeature(icon: Icons.support_agent, text: 'Interactive admin Help Center'),
Spacer(),
],
),
),
),
Expanded(
child: Container(
constraints: const BoxConstraints(minHeight: 590),
padding: const EdgeInsets.all(36),
child: SingleChildScrollView(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))),
Text(createMode ? 'Create admin account' : 'Sign in', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textDark)),
const SizedBox(height: 5),
Text(createMode ? 'Create an administrator profile for this PawLink prototype.' : 'Use your authorized administrator account.', style: const TextStyle(color: textMuted, fontSize: 12)),
const SizedBox(height: 24),
if (createMode) ...[
const FormLabel('Full Name'),
TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Administrator name', prefixIcon: Icon(Icons.person_outline))),
const SizedBox(height: 14),
],
const FormLabel('Email Address'),
TextField(controller: emailController, decoration: const InputDecoration(hintText: 'admin@pawlink.com', prefixIcon: Icon(Icons.email_outlined))),
const SizedBox(height: 14),
const FormLabel('Password'),
TextField(
controller: passwordController,
obscureText: hidePassword,
decoration: InputDecoration(
hintText: 'Password',
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(onPressed: () => setState(() => hidePassword = !hidePassword), icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
),
),
const SizedBox(height: 14),
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(color: lightCream, borderRadius: BorderRadius.circular(10)),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Checkbox(value: agreement, activeColor: forestGreen, onChanged: (v) => setState(() => agreement = v ?? false)),
const Expanded(child: Padding(padding: EdgeInsets.only(top: 8), child: Text('I will use PawLink information only for authorized administration and only disclose necessary owner-approved contact information when helping identify or reunite a pet.', style: TextStyle(fontSize: 10.5, color: textMuted, height: 1.4)))),
],
),
),
const SizedBox(height: 18),
SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: forestGreen), onPressed: continueToAdmin, child: Text(createMode ? 'Create Account' : 'Sign In to PawLink'))),
const SizedBox(height: 12),
Center(
child: TextButton(
onPressed: () => setState(() => createMode = !createMode),
child: Text(createMode ? 'Already have an account? Sign in' : 'Need an admin account? Create one'),
),
),
if (createMode)
const Padding(
padding: EdgeInsets.only(top: 6),
child: Text('Prototype note: connect this form to approved administrator provisioning and authentication before production deployment.', textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 9.5, height: 1.4)),
),
],
),
),
),
),
],
),
),
),
);
}
}