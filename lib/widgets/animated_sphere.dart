import 'package:flutter/material.dart';

class AnimatedSphere extends StatefulWidget {
  final double size;
  final Duration delay;
  const AnimatedSphere({super.key, required this.size, this.delay = Duration.zero});

  @override
  State<AnimatedSphere> createState() => _AnimatedSphereState();
}

class _AnimatedSphereState extends State<AnimatedSphere> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xAAFFFFFF),
              Color(0x77B19FFF),
            ],
          ),
          border: Border.all(
            color: const Color(0x4DFFFFFF), // Исправлено withOpacity
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51), // 0.2 opacity = 51 alpha
              blurRadius: 25,
              offset: const Offset(10, 10),
            ),
            BoxShadow(
              color: Colors.white.withAlpha(26), // 0.1 opacity = 26 alpha
              blurRadius: 15,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}