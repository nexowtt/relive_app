// screens/add_edit_memory_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';

class AddEditMemoryScreen extends StatefulWidget {
  final Memory? memory;
  final Function() onSave;

  const AddEditMemoryScreen({
    super.key,
    this.memory,
    required this.onSave,
  });

  @override
  State<AddEditMemoryScreen> createState() => _AddEditMemoryScreenState();
}

class _AddEditMemoryScreenState extends State<AddEditMemoryScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late MemoryService _memoryService;
  final List<File> _selectedImages = [];
  final List<String> _existingImagePaths = [];
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _memoryService = Provider.of<MemoryService>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.memory != null) {
      _titleController.text = widget.memory!.title;
      _descriptionController.text = widget.memory!.description;
      _selectedDate = widget.memory!.date;
      _existingImagePaths.addAll(widget.memory!.imagePaths);
    }
  }

  // Локальное сохранение изображений
  Future<List<String>> _saveImagesLocally() async {
    debugPrint('💾 === ЛОКАЛЬНОЕ СОХРАНЕНИЕ ИЗОБРАЖЕНИЙ ===');
    
    final List<String> savedPaths = [];
    final appDir = await getApplicationDocumentsDirectory();
    final memoryDir = Directory('${appDir.path}/memories');

    // Создаем директорию если не существует
    if (!await memoryDir.exists()) {
      await memoryDir.create(recursive: true);
      debugPrint('📁 Создана директория: ${memoryDir.path}');
    }

    for (int i = 0; i < _selectedImages.length; i++) {
      final imageFile = _selectedImages[i];
      
      try {
        // Проверяем, существует ли файл
        final exists = await imageFile.exists();
        if (!exists) {
          debugPrint('⚠️ Файл $i не существует: ${imageFile.path}');
          continue;
        }
        
        // Получаем размер файла
        final fileSize = await imageFile.length();
        debugPrint('📏 Размер файла $i: ${fileSize} байт');
        
        // Генерируем уникальное имя
        final timestamp = DateTime.now().millisecondsSinceEpoch + i;
        final random = DateTime.now().microsecondsSinceEpoch % 10000;
        final fileName = 'memory_${timestamp}_$random.jpg';
        final savePath = path.join(memoryDir.path, fileName);
        
        debugPrint('📸 Копирую фото $i:');
        debugPrint('   📁 Из: ${imageFile.path}');
        debugPrint('   📁 В: $savePath');
        
        // Копируем файл
        final savedFile = await imageFile.copy(savePath);
        
        // Проверяем результат
        final savedExists = await savedFile.exists();
        final savedSize = await savedFile.length();
        
        if (savedExists) {
          savedPaths.add(savedFile.path);
          debugPrint('✅ Фото $i сохранено успешно');
          debugPrint('   ✅ Путь: ${savedFile.path}');
          debugPrint('   ✅ Размер после сохранения: ${savedSize} байт');
        } else {
          debugPrint('❌ Фото $i не скопировалось');
        }
        
      } catch (e) {
          debugPrint('❌ Ошибка при сохранении фото $i: $e');
      }
    }

    debugPrint('💾 === УСПЕШНО СОХРАНЕНО: ${savedPaths.length} из ${_selectedImages.length} ===');
    return savedPaths;
  }

  Future<void> _saveMemory() async {
    debugPrint('🔍 === НАЧАЛО СОХРАНЕНИЯ ВОСПОМИНАНИЯ ===');
    debugPrint('📝 Заголовок: ${_titleController.text}');
    debugPrint('📝 Описание: ${_descriptionController.text}');
    debugPrint('📅 Дата: $_selectedDate');
    debugPrint('🖼️ Выбрано новых фото: ${_selectedImages.length}');
    debugPrint('🖼️ Существующие фото: ${_existingImagePaths.length}');
    debugPrint('👤 Пользователь: ${_memoryService.getCurrentUserId()}');

    if (_titleController.text.isEmpty) {
      _showErrorDialog('Введите заголовок воспоминания');
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      List<String> newImagePaths = [];
      
      // Сохраняем новые изображения локально
      if (_selectedImages.isNotEmpty) {
        debugPrint('📤 Сохраняю ${_selectedImages.length} новых изображений...');
        newImagePaths = await _saveImagesLocally();
      } else {
        debugPrint('📤 Новых изображений нет, пропускаю сохранение');
      }
      
      // Объединяем существующие и новые пути
      final allImagePaths = [..._existingImagePaths, ...newImagePaths];
      debugPrint('🖼️ Всего путей к изображениям: ${allImagePaths.length}');
      
      // Проверяем существование файлов
      for (int i = 0; i < allImagePaths.length; i++) {
        final file = File(allImagePaths[i]);
        final exists = await file.exists();
        debugPrint('   ${exists ? '✅' : '❌'} Файл $i: ${allImagePaths[i]}');
      }

      // Создаем объект Memory
      final memory = Memory(
        id: widget.memory?.id ?? '', // Пустой ID для новых воспоминаний
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        imagePaths: allImagePaths, // Локальные пути к файлам
        isFavorite: widget.memory?.isFavorite ?? false,
        createdAt: widget.memory?.createdAt ?? DateTime.now(),
      );

      debugPrint('🚀 Сохраняю в Firestore...');
      final success = await _memoryService.saveMemory(memory);
      
      if (mounted) {
        if (success) {
          debugPrint('🎉 ВОСПОМИНАНИЕ УСПЕШНО СОХРАНЕНО!');
          
          // Показываем уведомление об успехе
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Сохранено с ${allImagePaths.length} фото'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          widget.onSave();
          Navigator.pop(context);
        } else {
          debugPrint('❌ MemoryService вернул false при сохранении');
          
          // Удаляем сохраненные фото (откат изменений)
          for (final path in newImagePaths) {
            try {
              final file = File(path);
              if (await file.exists()) {
                await file.delete();
                debugPrint('🗑️ Удален файл после ошибки: $path');
              }
            } catch (e) {
              debugPrint('⚠️ Не удалось удалить файл $path: $e');
            }
          }
          
          _showErrorDialog('Не удалось сохранить воспоминание в базу данных');
        }
      }
    } catch (e) {
      debugPrint('❌ КРИТИЧЕСКАЯ ОШИБКА В _saveMemory:');
      debugPrint('❌ Тип ошибки: ${e.runtimeType}');
      debugPrint('❌ Сообщение: ${e.toString()}');
      
      if (mounted) {
        _showErrorDialog('Ошибка при сохранении: ${e.toString()}');
      }
    } finally {
      debugPrint('🔍 === КОНЕЦ ПРОЦЕССА СОХРАНЕНИЯ ===');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // --- СТАРЫЕ МЕТОДЫ (остаются без изменений) ---

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile>? selectedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (selectedFiles != null && selectedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(selectedFiles.map((xfile) => File(xfile.path)).toList());
        });
      }
    } catch (e) {
      _showErrorDialog('Ошибка при выборе фото: $e');
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      _showErrorDialog('Ошибка при съемке фото: $e');
    }
  }

  void _showImageSourceDialog() {
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
                const Text(
                  'Добавить фото',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ImageSourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Галерея',
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImageFromGallery();
                      },
                      color: const Color(0xFF9D84FF),
                    ),
                    _ImageSourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Камера',
                      onTap: () {
                        Navigator.of(context).pop();
                        _takePhotoWithCamera();
                      },
                      color: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImagePaths.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showErrorDialog(String message) {
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
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFF6B6B),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ошибка',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D84FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Понятно'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBackPressed() {
    if (_isSaving) return;
    
    if (_titleController.text.isNotEmpty || 
        _descriptionController.text.isNotEmpty || 
        _selectedImages.isNotEmpty) {
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
                      color: const Color(0xFFFFA726).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFFA726),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Несохраненные изменения',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'У вас есть несохраненные изменения. Вы уверены, что хотите выйти?',
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pop(context);
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
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildImagesSection() {
    final allImages = [
      ..._existingImagePaths.map((path) => _ImageType.existing(path)),
      ..._selectedImages.map((file) => _ImageType.newFile(file)),
    ];

    return Column(
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
              'ФОТОГРАФИИ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9D84FF), Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9D84FF).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                onPressed: _isSaving ? null : _showImageSourceDialog,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (allImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                final image = allImages[index];
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: image.when(
                          existing: (path) => Image.file(
                            File(path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          ),
                          newFile: (file) => Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          ),
                        ),
                      ),
                      
                      if (!_isSaving)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => image.when(
                              existing: (path) => _removeExistingImage(index),
                              newFile: (file) => _removeNewImage(index - _existingImagePaths.length),
                            ),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFFFF6B6B),
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          _buildEmptyImagesState(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D84FF), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.photo_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildEmptyImagesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF9D84FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF9D84FF),
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Нет фотографий',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Добавьте фото к вашему воспоминанию',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          CustomScrollView(
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
                    onPressed: _isSaving ? null : _onBackPressed,
                  ),
                ),
                title: Text(
                  widget.memory == null ? 'НОВОЕ ВОСПОМИНАНИЕ' : 'РЕДАКТИРОВАНИЕ',
                  style: const TextStyle(
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
                      onPressed: _isSaving ? null : _saveMemory,
                    ),
                  ),
                ],
                pinned: true,
              ),
              
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Заголовок
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
                      child: TextField(
                        controller: _titleController,
                        enabled: !_isSaving,
                        decoration: const InputDecoration(
                          labelText: 'Заголовок воспоминания',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9D84FF)),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Дата
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
                        onTap: _isSaving ? null : _selectDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Дата воспоминания',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9D84FF).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Color(0xFF9D84FF),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Описание
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
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 6,
                        enabled: !_isSaving,
                        decoration: const InputDecoration(
                          labelText: 'Описание воспоминания',
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
                    
                    const SizedBox(height: 24),
                    
                    // Фотографии
                    _buildImagesSection(),
                    
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
          
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF9D84FF)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Вспомогательный класс для работы с разными типами изображений
abstract class _ImageType {
  const factory _ImageType.existing(String path) = _ExistingImage._;
  const factory _ImageType.newFile(File file) = _NewImage._;

  T when<T>({
    required T Function(String) existing,
    required T Function(File) newFile,
  });
}

class _ExistingImage implements _ImageType {
  final String path;
  const _ExistingImage._(this.path);

  @override
  T when<T>({
    required T Function(String) existing,
    required T Function(File) newFile,
  }) {
    return existing(path);
  }
}

class _NewImage implements _ImageType {
  final File file;
  const _NewImage._(this.file);

  @override
  T when<T>({
    required T Function(String) existing,
    required T Function(File) newFile,
  }) {
    return newFile(file);
  }
}