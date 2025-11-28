import 'package:flutter/material.dart';
import '../services/memory_service.dart';
import '../models/memory.dart';
import '../welcome_screen.dart';
import '../services/time_capsule_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MemoryService _memoryService = MemoryService();
    final TimeCapsuleService _capsuleService = TimeCapsuleService();
  List<Memory> _memories = [];
  List<Memory> _favoriteMemories = [];
  List<dynamic> _capsules = []; // ← добавьте

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final memories = await _memoryService.getMemories();
    final favorites = await _memoryService.getFavoriteMemories();
    final capsules = await _capsuleService.getCapsules(); // ← добавьте
    
    if (mounted) {
      setState(() {
        _memories = memories;
        _favoriteMemories = favorites;
        _capsules = capsules; // ← добавьте
      });
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Выход',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Вы уверены, что хотите выйти из аккаунта?',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                // Закрываем все экраны и возвращаемся на Welcome Screen
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              child: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ПРОФИЛЬ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Аватар и основная информация
            _buildProfileHeader(),
            
            const SizedBox(height: 32),
            
            // Статистика
            _buildStatistics(),
            
            const SizedBox(height: 32),
            
            // Настройки
            _buildSettingsSection(),
            
            const SizedBox(height: 32),
            
            // Информация о приложении
            _buildAppInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Аватар
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF9D84FF).withAlpha(30),
            border: Border.all(
              color: const Color(0xFF9D84FF),
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: Color(0xFF9D84FF),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Имя пользователя
        const Text(
          'Пользователь ReLive',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Email
        const Text(
          'user@relive.com',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Кнопка редактирования профиля
        OutlinedButton(
          onPressed: () {
            // Будет реализовано позже
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF9D84FF),
            side: const BorderSide(color: Color(0xFF9D84FF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Редактировать профиль'),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Text(
            'СТАТИСТИКА',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                count: _memories.length.toString(),
                label: 'Воспоминания',
              ),
              _StatItem(
                count: _favoriteMemories.length.toString(),
                label: 'Избранные',
              ),
              _StatItem(
                count: _capsules.length.toString(), // Пока нет капсул времени
                label: 'Капсулы',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'НАСТРОЙКИ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _SettingsItem(
          icon: Icons.notifications_outlined,
          title: 'Уведомления',
          onTap: () {},
        ),
        
        _SettingsItem(
          icon: Icons.security_outlined,
          title: 'Конфиденциальность',
          onTap: () {},
        ),
        
        _SettingsItem(
          icon: Icons.language_outlined,
          title: 'Язык',
          value: 'Русский',
          onTap: () {},
        ),
        
        _SettingsItem(
          icon: Icons.dark_mode_outlined,
          title: 'Тема',
          value: 'Светлая',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'О ПРИЛОЖЕНИИ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _SettingsItem(
          icon: Icons.help_outline,
          title: 'Помощь и поддержка',
          onTap: () {},
        ),
        
        _SettingsItem(
          icon: Icons.info_outline,
          title: 'О приложении',
          value: 'Версия 1.0.0',
          onTap: () {},
        ),
        
        _SettingsItem(
          icon: Icons.star_outline,
          title: 'Оценить приложение',
          onTap: () {},
        ),
        
        _SettingsItem(
          icon: Icons.share_outlined,
          title: 'Поделиться приложением',
          onTap: () {},
        ),
        
        const SizedBox(height: 24),
        
        // Кнопка выхода
        Center(
          child: TextButton(
            onPressed: () => _logout(context),
            child: const Text(
              'Выйти из аккаунта',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Виджет для элемента статистики
class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9D84FF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Виджет для элемента настроек
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF9D84FF),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}