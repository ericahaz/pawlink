import 'package:flutter/material.dart';

import 'seasonal_controller.dart';
import 'seasonal_theme.dart';

class SeasonalShopPage extends StatelessWidget {
  const SeasonalShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SeasonalController.instance,
      builder: (context, _) {
        final controller = SeasonalController.instance;
        final active = controller.activeTheme;

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
                    'Free themes',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (active != null)
                    TextButton.icon(
                      onPressed: controller.removeTheme,
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
                      subtitle: Text(
                        '${theme.subtitle}\n${theme.decorations.join('  ')}',
                      ),
                      isThreeLine: true,
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
                'Theme music',
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

              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 34,
                        color: controller.musicEnabled && active != null
                            ? const Color(0xFF0F9F9A)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Theme Music',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed:
                            active == null || !controller.musicEnabled
                                ? null
                                : controller.togglePlayback,
                        icon: Icon(
                          controller.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          controller.isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Premium themes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFD49A32),
                  ),
                  title: const Text('Premium collection'),
                  subtitle: const Text(
                    'Coming Soon — no payment is available yet.',
                  ),
                  trailing: const Chip(
                    label: Text('Coming Soon'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}