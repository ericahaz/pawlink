part of pawlink_admin;

class HelpCenterContent extends StatefulWidget {
  const HelpCenterContent({super.key});

  @override
  State<HelpCenterContent> createState() => _HelpCenterContentState();
}

class _HelpCenterContentState extends State<HelpCenterContent> {
  String query = '';

  final List<Map<String, dynamic>> topics = const [
    {
      'icon': Icons.pets_outlined,
      'title': 'Pet Registration',
      'summary': 'Register pets and maintain their profiles.',
      'steps': [
        'Open Pet Registry and select Register Pet.',
        'Choose the animal type, available breed, age and sex.',
        'Select the primary owner and complete the identifying information.',
        'Save the record. PawLink creates the pet record and QR profile.',
      ],
    },
    {
      'icon': Icons.qr_code_2,
      'title': 'QR Profiles',
      'summary': 'View and check pet identification QR codes.',
      'steps': [
        'Open QR Registry from the admin menu.',
        'Find the registered pet and select View QR.',
        'Use Scan Preview to review the safe information a finder can see.',
        'A deployed PawLink URL is required before phone scans can open the live website.',
      ],
    },
    {
      'icon': Icons.report_outlined,
      'title': 'Missing, Found & Stray Reports',
      'summary': 'Review and resolve community animal reports.',
      'steps': [
        'Open All Reports or choose a report category from the sidebar.',
        'Open a report to review its animal details, location and evidence.',
        'For possible matches, compare the found report with a registered missing pet.',
        'Confirm only when the administrator has enough information, then mark the case solved.',
      ],
    },
    {
      'icon': Icons.people_outline,
      'title': 'Resident Accounts',
      'summary': 'Review residents and their registered pets.',
      'steps': [
        'Open Residents and locate the account.',
        'Use the three-dot menu and choose View Full Information.',
        'Review the account and its registered pet records.',
        'Delete Account is blocked while the resident still has an active pet.',
      ],
    },
    {
      'icon': Icons.heart_broken_outlined,
      'title': 'Pet Life Status',
      'summary': 'Manage active, missing and deceased pet records.',
      'steps': [
        'Open Pet Registry and locate the pet.',
        'Use the three-dot menu to open pet actions.',
        'Choose Mark as Deceased when appropriate and confirm the action.',
        'The historical pet record remains available even when the pet is deceased.',
      ],
    },
    {
      'icon': Icons.person_add_alt_1_outlined,
      'title': 'Co-owner Invitations',
      'summary': 'Connect another PawLink account to a pet.',
      'steps': [
        'Open Owners & Co-owners or Co-owner Invitations.',
        'Choose the pet and generate an invitation.',
        'Copy the invitation link or show its invitation QR code.',
        'Accepting an invitation adds that person as a co-owner; it never grants admin access.',
      ],
    },
    {
      'icon': Icons.history,
      'title': 'Activity Log',
      'summary': 'Review important administrator actions.',
      'steps': [
        'Open Activity Log from the System section.',
        'Review recent actions and their affected records.',
        'Use the log as an administrative history for important changes.',
      ],
    },
  ];

  void openTopic(Map<String, dynamic> topic) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pageBackground,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: softBeige,
              child: Icon(topic['icon'] as IconData, color: forestGreen),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(topic['title'] as String)),
          ],
        ),
        content: SizedBox(
          width: 540,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topic['summary'] as String, style: const TextStyle(color: textMuted)),
              const SizedBox(height: 18),
              for (int i = 0; i < (topic['steps'] as List).length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: softBeige,
                        child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: forestGreen, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text((topic['steps'] as List)[i] as String)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: forestGreen),
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void openSupport() {
    final subject = TextEditingController();
    final message = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: pageBackground,
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: forestGreen),
            SizedBox(width: 10),
            Text('Admin Support Request'),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Describe the PawLink issue or question. The prototype stores the request in the Activity Log.', style: TextStyle(color: textMuted)),
              const SizedBox(height: 16),
              const FormLabel('Subject'),
              TextField(controller: subject, decoration: const InputDecoration(hintText: 'Example: QR profile issue')),
              const SizedBox(height: 12),
              const FormLabel('Message'),
              TextField(controller: message, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe what happened...')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: forestGreen),
            onPressed: () {
              if (subject.text.trim().isEmpty || message.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a subject and message.')));
                return;
              }
              logActivity('Help Center support request', subject.text.trim());
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support request recorded in the prototype.')));
            },
            icon: const Icon(Icons.send_outlined),
            label: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = topics.where((topic) {
      final q = query.toLowerCase().trim();
      if (q.isEmpty) return true;
      return (topic['title'] as String).toLowerCase().contains(q) ||
          (topic['summary'] as String).toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [mutedGreen, forestGreen, deepForestGreen]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ADMIN HELP CENTER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                      SizedBox(height: 10),
                      Text('What do you need help with?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                      SizedBox(height: 7),
                      Text('Open a topic for step-by-step guidance or send a support request.', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.help_center_outlined, color: Colors.white70, size: 70),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              hintText: 'Search Help Center...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Help topics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final topic in filtered)
                HelpTopicCard(
                  icon: topic['icon'] as IconData,
                  title: topic['title'] as String,
                  text: topic['summary'] as String,
                  onTap: () => openTopic(topic),
                ),
            ],
          ),
          if (filtered.isEmpty) ...[
            const SizedBox(height: 15),
            const EmptyCard(text: 'No Help Center topic matches your search.'),
          ],
          const SizedBox(height: 28),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: softBeige, child: Icon(Icons.support_agent, color: forestGreen)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Still need help?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Create an administrator support request directly from the Help Center.', style: TextStyle(color: textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: forestGreen),
                    onPressed: openSupport,
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Support'),
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

