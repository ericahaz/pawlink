
import 'package:flutter/material.dart';

import 'seasonal_controller.dart';
import 'seasonal_theme.dart';

class SeasonalShopPage extends StatelessWidget {
  const SeasonalShopPage({super.key});

  Future<void> _confirmRemoveTheme(
    BuildContext context,
    SeasonalController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Seasonal Theme?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to remove the applied seasonal theme? '
            'Your PawLink app will return to its default appearance.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF075E63),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes, Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.removeTheme();
    }
  }

  Widget _premiumThemeCard({
    required IconData icon,
    required String name,
    required String description,
    bool trialTheme = false,
    bool trialActive = false,
    bool selected = false,
    String? countdown,
    VoidCallback? onApply,
  }) {
    final unlocked = trialTheme && trialActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F0E5),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: CircleAvatar(
            backgroundColor:
                const Color(0xFFD49A32).withValues(alpha: 0.14),
            child: Icon(
              icon,
              color: const Color(0xFFD49A32),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 5),
              if (trialTheme && unlocked)
                Text(
                  'FREE TRIAL · $countdown',
                  style: const TextStyle(
                    color: Color(0xFF16845B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else if (trialTheme)
                const Text(
                  'Trial expired · Premium required',
                  style: TextStyle(
                    color: Color(0xFFB45A45),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                const Text(
                  'Premium · Coming Soon',
                  style: TextStyle(
                    color: Color(0xFF9A8254),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          isThreeLine: true,
          trailing: selected
              ? const Chip(
                  label: Text('Applied'),
                )
              : unlocked
                  ? FilledButton(
                      onPressed: onApply,
                      child: const Text('Apply'),
                    )
                  : const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF9A8254),
                    ),
        ),
      ),
    );
  }

  Widget _pricingRow(String price, String description) {
    return Row(
      children: [
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF075E63),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SeasonalController.instance,
      builder: (context, _) {
        final controller = SeasonalController.instance;
        final active = controller.activeTheme;

        final christmas = SeasonalTheme.trialThemes.firstWhere(
          (theme) => theme.id == SeasonalThemeId.christmas,
        );

        final spooky = SeasonalTheme.trialThemes.firstWhere(
          (theme) => theme.id == SeasonalThemeId.halloween,
        );

        final christmasSelected = active?.id == christmas.id;
        final spookySelected = active?.id == spooky.id;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Seasonal Themes'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make PawLink feel more you!',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choose a free seasonal look. Decorations appear across the app.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Free Collection',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (active != null)
                    TextButton.icon(
                      onPressed: () {
                        _confirmRemoveTheme(context, controller);
                      },
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Remove theme'),
                    ),
                ],
              ),

              ...SeasonalTheme.freeThemes.map((theme) {
                final selected = active?.id == theme.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.secondary,
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.primary.withValues(alpha: 0.14),
                        child: Icon(
                          theme.icon,
                          color: theme.primary,
                        ),
                      ),
                      title: Text(
                        theme.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(theme.subtitle),
                      trailing: selected
                          ? const Chip(
                              label: Text('Applied'),
                            )
                          : FilledButton(
                              onPressed: () {
                                controller.applyTheme(theme);
                              },
                              child: const Text('Apply'),
                            ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              const Text(
                'Theme Music',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Music ON/OFF'),
                subtitle: const Text(
                  'Turn seasonal background music on or off.',
                ),
                value: controller.musicEnabled,
                onChanged: controller.setMusicEnabled,
              ),

              const SizedBox(height: 20),

              const Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFD49A32),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premium Collection',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text('Premium'),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                'Discover exclusive themes for your PawLink experience.',
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 14),

              _premiumThemeCard(
                icon: Icons.celebration_rounded,
                name: 'New Year Celebration',
                description: 'Welcome the new year with a festive look.',
              ),

              _premiumThemeCard(
                icon: Icons.favorite_rounded,
                name: 'Valentine’s Day',
                description: 'A lovely theme filled with hearts and romance.',
              ),

              _premiumThemeCard(
                icon: Icons.eco_rounded,
                name: 'Autumn',
                description: 'Enjoy warm colors and cozy autumn decorations.',
              ),

              _premiumThemeCard(
                icon: Icons.pets_rounded,
                name: 'Pet Lovers',
                description: 'Celebrate the love we have for our pets.',
              ),

              _premiumThemeCard(
                icon: Icons.cake_rounded,
                name: 'Birthday Party',
                description: 'Make every celebration extra special.',
              ),

              _premiumThemeCard(
                icon: christmas.icon,
                name: christmas.name,
                description: christmas.subtitle,
                trialTheme: true,
                trialActive: controller.trialActive,
                selected: christmasSelected,
                countdown: controller.trialCountdownLabel,
                onApply: () => controller.applyTheme(christmas),
              ),

              _premiumThemeCard(
                icon: spooky.icon,
                name: spooky.name,
                description: spooky.subtitle,
                trialTheme: true,
                trialActive: controller.trialActive,
                selected: spookySelected,
                countdown: controller.trialCountdownLabel,
                onApply: () => controller.applyTheme(spooky),
              ),

              const SizedBox(height: 16),

              const Text(
                'Premium Pricing',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _pricingRow(
                        '₱29/month',
                        '1 Premium Collection',
                      ),
                      const Divider(height: 24),
                      _pricingRow(
                        '₱100/month',
                        'All Premium Collections',
                      ),
                      const Divider(height: 24),
                      _pricingRow(
                        '₱399/year',
                        'All Premium Collections',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFEBD9B4),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFAD812F),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Christmas Cheer and Spooky Season are temporarily '
                        'available during the 30-day trial. After expiration, '
                        'both themes will automatically return to Premium. '
                        'Premium subscription and payment features are not '
                        'yet available.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
