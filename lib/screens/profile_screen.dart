import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:relive_app/app_auth_provider.dart';
import 'package:relive_app/welcome_screen.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  UserProfile? _userProfile;
  // final MemoryService _memoryService = MemoryService();
  // final TimeCapsuleService _capsuleService = TimeCapsuleService();
  // List<Memory> _memories = [];
  // List<Memory> _favoriteMemories = [];
  // List<dynamic> _capsules = [];

  @override
  void initState() {
    super.initState();
    // _loadStatistics();
     _loadUserProfile();
  }

Future<void> _loadUserProfile() async {
  final profile = await _profileService.getCurrentUserProfile();
  if (mounted) {
    setState(() {
      _userProfile = profile;
    });
  }
}
  // Future<void> _loadStatistics() async {
  //   // Ваш код загрузки статистики
  //   // final memories = await _memoryService.getMemories();
  //   // final favorites = await _memoryService.getFavoriteMemories();
  //   // final capsules = await _capsuleService.getCapsules();
    
  //   if (mounted) {
  //     setState(() {
  //       // _memories = memories;
  //       // _favoriteMemories = favorites;
  //       // _capsules = capsules;
  //     });
  //   }
  // }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Выход',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Вы уверены, что хотите выйти из аккаунта?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Закрываем диалог
                          Navigator.of(context).pop();
                          
                          // Выполняем выход
                          await authProvider.signOut();
                          
                          // Переходим на экран приветствия с очисткой истории
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Выйти'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: const Text(
              'ПРОФИЛЬ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  
                  const SizedBox(height: 32),
                  
                  // _buildStatistics(), // Раскомментируйте когда добавите сервисы
                  
                  // const SizedBox(height: 32),
                  
                  _buildSettingsSection(),
                  
                  const SizedBox(height: 32),
                  
                  _buildAppInfoSection(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    final email = user?.email ?? 'user@relive.com';
     final displayName = _userProfile?.displayName ?? 
                      user?.displayName ?? 
                      user?.email?.split('@').first ?? 
                      'Пользователь ReLive';
    final bio = _userProfile?.bio;


    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D84FF), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D84FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          if (bio != null && bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

          const SizedBox(height: 8),
          
          // Email
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          if (_userProfile?.birthDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Родился(ась): ${_formatDate(_userProfile!.birthDate!)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],

          const SizedBox(height: 16),
          
          OutlinedButton(
            onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  initialProfile: _userProfile,
                  onProfileUpdated: _loadUserProfile,
                ),
              ),
            );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Редактировать профиль'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    // Временно закомментировано - раскомментируйте когда добавите сервисы
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D84FF), Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'СТАТИСТИКА',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                count: "0", // _memories.length.toString(),
                label: 'Воспоминания',
                gradient: const [Color(0xFF9D84FF), Color(0xFF6C63FF)],
                icon: Icons.photo_library_rounded,
              ),
              _StatItem(
                count: "0", // _favoriteMemories.length.toString(),
                label: 'Избранные',
                gradient: const [Color(0xFFFF6B95), Color(0xFFFF8E6C)],
                icon: Icons.favorite_rounded,
              ),
              _StatItem(
                count: "0", // _capsules.length.toString(),
                label: 'Капсулы',
                gradient: const [Color(0xFF61C3FF), Color(0xFF6C63FF)],
                icon: Icons.hourglass_full_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D84FF), Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'НАСТРОЙКИ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _SettingsItem(
            icon: Icons.notifications_active_rounded,
            title: 'Уведомления',
            color: const Color(0xFFFF6B95),
            onTap: () {},
          ),
          
          _SettingsItem(
            icon: Icons.security_rounded,
            title: 'Конфиденциальность',
            color: const Color(0xFF61C3FF),
            onTap: () {},
          ),
          
          _SettingsItem(
            icon: Icons.language_rounded,
            title: 'Язык',
            value: 'Русский',
            color: const Color(0xFF9D84FF),
            onTap: () {},
          ),
          
          _SettingsItem(
            icon: Icons.dark_mode_rounded,
            title: 'Тема',
            value: 'Светлая',
            color: const Color(0xFFFF8E6C),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D84FF), Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'О ПРИЛОЖЕНИИ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _SettingsItem(
            icon: Icons.help_center_rounded,
            title: 'Помощь и поддержка',
            color: const Color(0xFF9D84FF),
            onTap: () {},
          ),
          
          _SettingsItem(
            icon: Icons.info_rounded,
            title: 'О приложении',
            value: 'Версия 1.0.0',
            color: const Color(0xFF61C3FF),
            onTap: () {},
          ),
          
          _SettingsItem(
            icon: Icons.star_rounded,
            title: 'Оценить приложение',
            color: const Color(0xFFFF8E6C),
            onTap: () {},
          ),
          
          _SettingsItem(
            icon: Icons.share_rounded,
            title: 'Поделиться приложением',
            color: const Color(0xFFFF6B95),
            onTap: () {},
          ),
          
          const SizedBox(height: 16),
          
          // Кнопка выхода
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E6C)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _logout(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Выйти из аккаунта',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 String _formatDate(DateTime date) {
  final months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final List<Color> gradient;
  final IconData icon;

  const _StatItem({
    required this.count,
    required this.label,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
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
  final Color color;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}