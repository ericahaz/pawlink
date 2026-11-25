part of pawlink_admin;

class ReportsPage extends StatefulWidget {
  final String initialFilter;
  final VoidCallback onRefresh;

  const ReportsPage({
    super.key,
    required this.initialFilter,
    required this.onRefresh,
  });

  @override
  State<ReportsPage> createState() =>
      _ReportsPageState();
}

class _ReportsPageState
    extends State<ReportsPage> {
  late String filter;
  final AdminReportService _reportService = AdminReportService();

  @override
  void initState() {
    super.initState();
    filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(
    covariant ReportsPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialFilter !=
        widget.initialFilter) {
      filter = widget.initialFilter;
    }
  }

  Stream<List<AnimalReport>> get _reportsStream {
    switch (filter) {
      case 'All':
        return _reportService.getReportsStream();
      case 'Missing':
        return _reportService.getReportsByTypeStream('lost');
      case 'Found':
        return _reportService.getReportsByTypeStream('found');
      case 'Stray':
        return _reportService.getReportsByTypeStream('stray');
      case 'Solved':
        return _reportService.getReportsStream()
            .map((reports) => reports.where((r) => r.status == 'resolved' || r.status == 'Solved').toList());
      default:
        return _reportService.getReportsStream();
    }
  }

  void refresh() {
    setState(() {});
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnimalReport>>(
      stream: _reportsStream,
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final visible = filter == 'Solved'
            ? reports.where((r) => r.status == 'resolved' || r.status == 'Solved').toList()
            : reports;

        return AdminPage(
          title: filter == 'All'
              ? 'Community Reports'
              : '$filter Reports',
          subtitle:
              'Review animal reports, evidence photos and case status.',
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SearchField(
                hint:
                    'Search report, reporter, pet or location...',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in [
                    'All',
                    'Missing',
                    'Found',
                    'Stray',
                    'Solved',
                  ])
                    ChoiceChip(
                      label: Text(option),
                      selected: filter == option,
                      selectedColor: softBeige,
                      onSelected: (_) {
                        setState(() {
                          filter = option;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (visible.isEmpty)
                const EmptyCard(
                  text:
                      'No reports found in this category.',
                ),
              for (final report in visible)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
                  child: ReportCard(
                    report: report,
                    onChanged: refresh,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

