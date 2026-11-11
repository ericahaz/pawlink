
part of pawlink_admin;

// ============================================================
// PAWLINK ADMIN SHELL
// Main layout, navigation, notifications and inactivity logout.
// ============================================================

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int selectedPage = 0;

  Timer? _inactivityTimer;

  static const Duration _inactivityLimit =
      Duration(minutes: 15);

  @override
  void initState() {
    super.initState();

    adminPageRequest.addListener(_handlePageRequest);

    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    adminPageRequest.removeListener(_handlePageRequest);

    super.dispose();
  }

  // ==========================================================
  // PAGE NAVIGATION
  // ==========================================================

  void _handlePageRequest() {
    final requestedPage = adminPageRequest.value;

    if (requestedPage >= 0) {
      _selectPage(requestedPage);
      adminPageRequest.value = -1;
    }
  }

  void _selectPage(int index) {
    if (!mounted) return;

    setState(() {
      selectedPage = index;
    });

    _resetInactivityTimer();

    // Close the drawer after selecting a page on mobile.
    if (MediaQuery.of(context).size.width < 900) {
      Navigator.of(context).maybePop();
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================
  // AUTOMATIC LOGOUT
  // ==========================================================

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(
      _inactivityLimit,
      _logout,
    );
  }

  void _logout() {
    if (!mounted) return;

    _inactivityTimer?.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginPage(),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // EXISTING FEATURE PAGES
  // ==========================================================

  Widget _buildCurrentPage() {
    switch (selectedPage) {
      case 0:
        return DashboardPage(
          onNavigate: _selectPage,
        );

      case 1:
        return ResidentsPage(
          onRefresh: _refresh,
        );

      case 2:
      case 3:
        return PetRegistryPage(
          onRefresh: _refresh,
        );

      case 4:
        return PetCategoriesPage(
          onRefresh: _refresh,
        );

      case 5:
        return OwnershipPage(
          onRefresh: _refresh,
        );

      case 6:
        return ReportsPage(
          initialFilter: 'All',
          onRefresh: _refresh,
        );

      case 7:
        return ReportsPage(
          initialFilter: 'Missing',
          onRefresh: _refresh,
        );

      case 8:
        return ReportsPage(
          initialFilter: 'Found',
          onRefresh: _refresh,
        );

      case 9:
        return ReportsPage(
          initialFilter: 'Stray',
          onRefresh: _refresh,
        );

      case 10:
        return ReportsPage(
          initialFilter: 'Solved',
          onRefresh: _refresh,
        );

      case 11:
        return QRRegistryPage(
          onRefresh: _refresh,
        );

      case 12:
        return InvitationsPage(
          onRefresh: _refresh,
        );

      case 13:
        return ActivityLogPage(
          onRefresh: _refresh,
        );

      case 14:
        return const AdminAccountPage();

      case 15:
        return const HelpCenterPage();

      case 16:
        return const BarangaySupportPage();

      case 17:
        return const SupportInboxPage();

      default:
        return DashboardPage(
          onNavigate: _selectPage,
        );
    }
  }

  // ==========================================================
  // SIDEBAR
  // ==========================================================

  Widget _buildSidebar() {
    return AdminSidebar(
      selected: selectedPage,
      onSelected: _selectPage,
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader({bool mobile = false}) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 14 : 30,
      ),
      decoration: const BoxDecoration(
        color: pageBackground,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (mobile) ...[
            const Icon(
              Icons.pets_rounded,
              color: forestGreen,
              size: 25,
            ),
            const SizedBox(width: 9),
          ],

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kamusta, Administrator!',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Welcome to your PawLink administration portal.',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const NotificationBell(),

          const SizedBox(width: 5),

          IconButton(
            tooltip: 'Help Center',
            onPressed: () {
              _selectPage(15);
            },
            icon: const Icon(
              Icons.help_outline_rounded,
              color: forestGreen,
            ),
          ),

          if (!mobile) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: softBeige,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: borderColor),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: forestGreen,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Administrator',
                    style: TextStyle(
                      fontSize: 11,
                      color: textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // DESKTOP LAYOUT
  // ==========================================================

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(),

            Expanded(
              child: Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: PawLinkAnimatedBackground(
                      child: _buildCurrentPage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MOBILE / TABLET LAYOUT
  // ==========================================================

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: pageBackground,

      drawer: Drawer(
        width: 255,
        backgroundColor: pageBackground,
        child: SafeArea(
          child: _buildSidebar(),
        ),
      ),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: SafeArea(
          child: Builder(
            builder: (context) {
              return Row(
                children: [
                  IconButton(
                    tooltip: 'Open navigation',
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: forestGreen,
                    ),
                  ),

                  Expanded(
                    child: _buildHeader(mobile: true),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      body: PawLinkAnimatedBackground(
        child: _buildCurrentPage(),
      ),
    );
  }

  // ==========================================================
  // MAIN BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,

      onPointerDown: (_) => _resetInactivityTimer(),
      onPointerMove: (_) => _resetInactivityTimer(),
      onPointerSignal: (_) => _resetInactivityTimer(),

      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return _buildMobileLayout();
          }

          return _buildDesktopLayout();
        },
      ),
    );
  }
}
