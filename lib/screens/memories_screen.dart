import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';
import 'add_edit_memory_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final MemoryService _memoryService = MemoryService();
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final memories = await _memoryService.getMemories();
    if (mounted) {
      setState(() {
        _memories = memories;
      });
    }
  }

  void _addNewMemory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMemoryScreen(
          onSave: _loadMemories,
        ),
      ),
    );
  }

  void _editMemory(Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMemoryScreen(
          memory: memory,
          onSave: _loadMemories,
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Memory memory) async {
    await _memoryService.toggleFavorite(memory.id);
    if (mounted) {
      _loadMemories();
    }
  }

  Future<void> _deleteMemory(Memory memory) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить воспоминание?'),
          content: Text('Вы уверены, что хотите удалить "${memory.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      await _memoryService.deleteMemory(memory.id);
      _loadMemories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'МОИ ВОСПОМИНАНИЯ',
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
      body: _memories.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Пока нет воспоминаний',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Нажмите + чтобы добавить первое воспоминание',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _memories.length,
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return _buildMemoryCard(memory);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMemory,
        backgroundColor: const Color(0xFF9D84FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMemoryCard(Memory memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editMemory(memory),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка избранного
              Row(
                children: [
                  Expanded(
                    child: Text(
                      memory.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: memory.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(memory),
                  ),
                ],
              ),
              
              // Дата
              Text(
                _formatDate(memory.date),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Описание
              Text(
                memory.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 12),
              
              // Фотографии (превью)
              if (memory.imagePaths.isNotEmpty) ...[
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: memory.imagePaths.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: const Icon(Icons.photo, size: 30, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Кнопка удаления
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _deleteMemory(memory),
                  child: const Text(
                    'Удалить',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}