import 'package:flutter/material.dart';
import 'widgets/animated_sphere.dart';
import 'login_screen.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    _textController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAE6FF),
                Color(0xFFB79CFF),
                Color(0xFF9D84FF),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Анимированные шары
              const Positioned(
                top: 100,
                left: 60,
                child: AnimatedSphere(size: 100, delay: Duration(milliseconds: 200)),
              ),
              const Positioned(
                top: 300,
                right: 80,
                child: AnimatedSphere(size: 110, delay: Duration(milliseconds: 400)),
              ),
              const Positioned(
                bottom: 100,
                left: 100,
                child: AnimatedSphere(size: 90, delay: Duration(milliseconds: 600)),
              ),

              // Анимированный текст
              Positioned(
                left: 40,
                top: 220,
                child: SlideTransition(
                  position: _textAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "ReLive",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Make your\nmemories eternal",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Кнопка Get Started
              Positioned(
                bottom: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9D84FF),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}