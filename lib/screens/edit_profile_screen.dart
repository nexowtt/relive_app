// screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? initialProfile;
  final Function() onProfileUpdated;

  const EditProfileScreen({
    super.key,
    this.initialProfile,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _birthDateController;
  
  DateTime? _selectedBirthDate;
  bool _isSaving = false;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    
    _displayNameController = TextEditingController(
      text: widget.initialProfile?.displayName ?? '',
    );
    
    _bioController = TextEditingController(
      text: widget.initialProfile?.bio ?? '',
    );
    
    _birthDateController = TextEditingController(
      text: widget.initialProfile?.birthDate != null
          ? _formatDate(widget.initialProfile!.birthDate!)
          : '',
    );
    
    _selectedBirthDate = widget.initialProfile?.birthDate;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9D84FF),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving || _currentUser == null) return;
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _profileService.updateProfile(
        userId: _currentUser.uid,
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        birthDate: _selectedBirthDate,
      );

      if (success && mounted) {
        // Обновляем email в Firebase Auth если нужно
        if (_displayNameController.text.trim().isNotEmpty) {
          await _currentUser.updateDisplayName(_displayNameController.text.trim());
        }
        
        widget.onProfileUpdated();
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: _isSaving ? Colors.grey : Colors.black54,
                ),
                onPressed: _isSaving ? null : () => Navigator.pop(context),
              ),
            ),
            title: const Text(
              'РЕДАКТИРОВАНИЕ ПРОФИЛЯ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isSaving ? Colors.grey : const Color(0xFF9D84FF),
                  shape: BoxShape.circle,
                  boxShadow: _isSaving ? null : [
                    BoxShadow(
                      color: const Color(0xFF9D84FF).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_rounded, color: Colors.white),
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ),
            ],
            pinned: true,
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Аватар
                    GestureDetector(
                      onTap: () {
                        // TODO: Реализовать выбор фото
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF9D84FF).withAlpha(30),
                              border: Border.all(
                                color: const Color(0xFF9D84FF).withOpacity(0.3),
                                width: 3,
                              ),
                              image: widget.initialProfile?.photoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.initialProfile!.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: widget.initialProfile?.photoUrl == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 60,
                                    color: Color(0xFF9D84FF),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF9D84FF),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 20,
                                color: Color(0xFF9D84FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Имя пользователя
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _displayNameController,
                        enabled: !_isSaving,
                        decoration: const InputDecoration(
                          labelText: 'Имя пользователя',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                          prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF9D84FF)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9D84FF)),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите имя пользователя';
                          }
                          if (value.trim().length < 2) {
                            return 'Имя должно быть не менее 2 символов';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email (только для просмотра)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email_rounded, color: Colors.grey),
                        title: Text(
                          _currentUser?.email ?? 'Не указан',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        subtitle: const Text(
                          'Email (нельзя изменить)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Дата рождения
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: _isSaving ? null : _selectBirthDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9D84FF).withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.cake_rounded,
                                  color: Color(0xFF9D84FF),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _birthDateController.text.isEmpty
                                          ? 'Дата рождения'
                                          : _birthDateController.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _birthDateController.text.isEmpty
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Нажмите чтобы выбрать дату',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // О себе
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _bioController,
                        enabled: !_isSaving,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'О себе',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                          alignLabelWithHint: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9D84FF)),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Подсказка
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9D84FF).withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF9D84FF).withAlpha(50),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: Color(0xFF9D84FF),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ваши данные сохраняются только в вашем аккаунте и не видны другим пользователям',
                              style: TextStyle(
                                color: Color(0xFF9D84FF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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