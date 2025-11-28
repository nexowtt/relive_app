import 'package:flutter/material.dart';
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
  final _memoryService = MemoryService();
  final List<String> _imagePaths = [];
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.memory != null) {
      _titleController.text = widget.memory!.title;
      _descriptionController.text = widget.memory!.description;
      _selectedDate = widget.memory!.date;
      _imagePaths.addAll(widget.memory!.imagePaths);
    }
  }

  Future<void> _pickImage() async {
    // Временно используем заглушку для изображений
    setState(() {
      _imagePaths.add('assets/placeholder.jpg'); // Заглушка
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMemory() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите заголовок')),
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final memory = Memory(
        id: widget.memory?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        imagePaths: _imagePaths,
        isFavorite: widget.memory?.isFavorite ?? false,
        createdAt: widget.memory?.createdAt ?? DateTime.now(),
      );

      final success = await _memoryService.saveMemory(memory);
      
      if (mounted) {
        if (success) {
          widget.onSave();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при сохранении')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
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

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.memory == null ? 'Новое воспоминание' : 'Редактировать',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save, color: Color(0xFF9D84FF)),
                  onPressed: _saveMemory,
                ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // Заголовок
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9D84FF)),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                
                const SizedBox(height: 20),
                
                // Дата
                InkWell(
                  onTap: _isSaving ? null : _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Дата',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(_selectedDate)),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Описание
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9D84FF)),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Добавление фото
                Row(
                  children: [
                    const Text(
                      'Фотографии',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D84FF),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Добавить фото'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Список фотографий
                if (_imagePaths.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagePaths.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: const Icon(Icons.photo, size: 40, color: Colors.grey),
                            ),
                            if (!_isSaving)
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
          
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}