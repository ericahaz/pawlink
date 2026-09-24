import 'package:flutter/material.dart';

class PawLinkNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const PawLinkNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return _DesktopSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: onItemSelected,
          );
        }

        return _MobileNavigation(
          selectedIndex: selectedIndex,
          onItemSelected: onItemSelected,
        );
      },
    );
  }
}

// ============================================================
// DESKTOP SIDEBAR
// ============================================================

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // PAWLINK LOGO
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PawLink',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF173B3B),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // NAVIGATION
            // ==================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _SidebarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),

                  _SidebarItem(
                    icon: Icons.pets_rounded,
                    label: 'My Pets',
                    selected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),

                  _SidebarItem(
                    icon: Icons.campaign_rounded,
                    label: 'Report',
                    selected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ACCOUNT SECTION
                  // ==================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  _SidebarItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Account',
                    selected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),

                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    selected: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                ],
              ),
            ),

            // ==================================================
            // HELP CARD
            // ==================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF008080),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Need help?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF173B3B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contact your barangay for assistance.',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SIDEBAR ITEM
// ============================================================

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE6F5F3) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected
                      ? const Color(0xFF008080)
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF006B6B)
                          : const Color(0xFF4D5B5B),
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MOBILE NAVIGATION
// ============================================================

class _MobileNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _MobileNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              _MobileItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),

              _MobileItem(
                icon: Icons.pets_rounded,
                label: 'My Pets',
                selected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),

              _MobileItem(
                icon: Icons.campaign_rounded,
                label: 'Report',
                selected: selectedIndex == 2,
                onTap: () => onItemSelected(2),
              ),

              _MobileItem(
                icon: Icons.person_outline_rounded,
                label: 'Account',
                selected: selectedIndex == 3,
                onTap: () => onItemSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MOBILE ITEM
// ============================================================

class _MobileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MobileItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 21,
                color: selected
                    ? const Color(0xFF008080)
                    : Colors.grey.shade500,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF008080)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
