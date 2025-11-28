import 'package:flutter/material.dart';
import '../models/time_capsule.dart';
import '../services/time_capsule_service.dart';

class AddTimeCapsuleScreen extends StatefulWidget {
  final Function() onSave;

  const AddTimeCapsuleScreen({
    super.key,
    required this.onSave,
  });

  @override
  State<AddTimeCapsuleScreen> createState() => _AddTimeCapsuleScreenState();
}

class _AddTimeCapsuleScreenState extends State<AddTimeCapsuleScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _capsuleService = TimeCapsuleService();
  DateTime _selectedOpenDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  Future<void> _selectOpenDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedOpenDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedOpenDate) {
      setState(() {
        _selectedOpenDate = picked;
      });
    }
  }

  Future<void> _saveCapsule() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите заголовок')),
      );
      return;
    }

    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите сообщение')),
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final capsule = TimeCapsule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        message: _messageController.text,
        creationDate: DateTime.now(),
        openDate: _selectedOpenDate,
      );

      final success = await _capsuleService.saveCapsule(capsule);
      
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

  @override
  Widget build(BuildContext context) {
    final daysUntilOpen = _selectedOpenDate.difference(DateTime.now()).inDays;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Новая капсула времени',
          style: TextStyle(color: Colors.black),
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
                  icon: const Icon(Icons.save, color: Color(0xFFB79CFF)),
                  onPressed: _saveCapsule,
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
                    labelText: 'Заголовок капсулы',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB79CFF)),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                
                const SizedBox(height: 20),
                
                // Дата открытия
                InkWell(
                  onTap: _isSaving ? null : _selectOpenDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Дата открытия',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDate(_selectedOpenDate)),
                            Text(
                              'Через $daysUntilOpen дней',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Сообщение
                TextField(
                  controller: _messageController,
                  maxLines: 8,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Ваше сообщение в будущее',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB79CFF)),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Подсказка
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB79CFF).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 20, color: Color(0xFFB79CFF)),
                          SizedBox(width: 8),
                          Text(
                            'Идеи для сообщения:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB79CFF),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('• Цели на будущее'),
                      Text('• Советы себе'),
                      Text('• Впечатления о сегодняшнем дне'),
                      Text('• Мечты и планы'),
                    ],
                  ),
                ),
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