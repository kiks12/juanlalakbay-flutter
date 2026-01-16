import 'package:flutter/material.dart';
import 'package:juanlalakbay/widgets/health_bar.dart';

class CharacterGroup extends StatefulWidget {
  final List<String> names;
  final int currentHealth;
  final HealthBarType type;
  final double size;

  const CharacterGroup({
    super.key,
    required this.names,
    required this.currentHealth,
    required this.type,
    this.size = 90,
  });

  @override
  State<CharacterGroup> createState() => CharacterGroupState();
}

class CharacterGroupState extends State<CharacterGroup>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shake;
  late Animation<Color?> _flash;
  late AnimationController _idleController;
  late Animation<double> _idleBob;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _idleBob = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(_controller);

    _flash = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withOpacity(0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void damage() {
    _idleController.stop();
    _controller.forward(from: 0).whenComplete(() {
      _idleController.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHealthBar(),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: Listenable.merge([_controller, _idleController]),
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(_shake.value, _idleBob.value),
              child: _buildLayout(),
            );
          },
        ),
      ],
    );
  }

  // ───────────────── HEALTH BAR ─────────────────
  Widget _buildHealthBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < widget.currentHealth;
        return Container(
          width: widget.size / 2,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: filled ? _barColor() : Colors.grey.shade400,
            border: Border.all(color: Colors.black54, width: 1.5),
          ),
        );
      }),
    );
  }

  Color _barColor() =>
      widget.type == HealthBarType.player ? Colors.green : Colors.red;

  // ───────────────── LAYOUT LOGIC ─────────────────
  Widget _buildLayout() {
    switch (widget.names.length) {
      case 1:
        return Center(child: _buildSingle(widget.names[0]));
      case 2:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: widget.names.map(_buildCharacter).toList(),
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCharacter(widget.names[0]),
                const SizedBox(width: 8),
                _buildCharacter(widget.names[1]),
              ],
            ),
            const SizedBox(height: 8),
            _buildCharacter(widget.names[2]),
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCharacter(widget.names[0]),
                const SizedBox(width: 8),
                _buildCharacter(widget.names[1]),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCharacter(widget.names[2]),
                const SizedBox(width: 8),
                _buildCharacter(widget.names[3]),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildSingle(String name) => Center(child: _buildCharacter(name));

  // ───────────────── CHARACTER TILE ─────────────────
  Widget _buildCharacter(String name) {
    return Stack(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/characters/$name.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // DAMAGE FLASH
        if (_controller.isAnimating)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _flash.value,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
      ],
    );
  }
}
