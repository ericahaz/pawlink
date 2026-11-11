part of pawlink_admin;

class PawLinkAnimatedBackground extends StatefulWidget {
  final Widget child;

  const PawLinkAnimatedBackground({
    super.key,
    required this.child,
  });

  @override
  State<PawLinkAnimatedBackground> createState() =>
      _PawLinkAnimatedBackgroundState();
}

class _PawLinkAnimatedBackgroundState extends State<PawLinkAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: pageBackground),
        ),

        // Visible live background movement.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_controller.value);

                return Stack(
                  children: [
                    Positioned(
                      left: -80 + (t * 130),
                      top: 85 + (t * 55),
                      child: _MovingRing(
                        size: 235,
                        opacity: .13,
                      ),
                    ),
                    Positioned(
                      right: -95 + (t * 125),
                      top: 275 - (t * 85),
                      child: _MovingRing(
                        size: 315,
                        opacity: .10,
                      ),
                    ),
                    Positioned(
                      left: 310 + (t * 150),
                      bottom: -125 + (t * 75),
                      child: _MovingRing(
                        size: 350,
                        opacity: .075,
                      ),
                    ),
                    Positioned(
                      right: 95 + (t * 90),
                      bottom: 115 + (t * 65),
                      child: Transform.rotate(
                        angle: -.18 + (t * .34),
                        child: Icon(
                          Icons.pets,
                          size: 82,
                          color: forestGreen.withValues(alpha: .11),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 115 + (t * 95),
                      top: 350 - (t * 65),
                      child: Transform.rotate(
                        angle: .20 - (t * .28),
                        child: Icon(
                          Icons.pets,
                          size: 43,
                          color: forestGreen.withValues(alpha: .075),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 390 - (t * 110),
                      top: 115 + (t * 55),
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: forestGreen.withValues(alpha: .14),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // The actual admin UI remains above the animation.
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _MovingRing extends StatelessWidget {
  final double size;
  final double opacity;

  const _MovingRing({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: forestGreen.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}

