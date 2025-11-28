import 'package:flutter/material.dart';
import 'screens/memories_screen.dart';
import 'screens/favorite_moments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/time_capsule_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'ReLive',
          style: TextStyle(
            color: Color(0xFF9D84FF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие с датой
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ГЛАВНАЯ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Основные разделы
            _buildSectionCard(
              context,
              'МОИ ВОСПОМИНАНИЯ',
              Icons.photo_library_outlined,
              const Color(0xFF9D84FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemoriesScreen()),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildSectionCard(
              context,
              'ЛЮБИМЫЕ МОМЕНТЫ',
              Icons.favorite_outline,
              const Color(0xFF6C63FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteMomentsScreen()),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildSectionCard(
              context,
              'КАПСУЛА ВРЕМЕНИ',
              Icons.time_to_leave_outlined,
              const Color(0xFFB79CFF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimeCapsuleScreen()),
                );
              },
            ),
            
            const Spacer(),
            
            // Footer информация
            const Center(
              child: Text(
                'ReLive - Make your memories eternal',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}