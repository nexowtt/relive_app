import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';

class FavoriteMomentsScreen extends StatefulWidget {
  const FavoriteMomentsScreen({super.key});

  @override
  State<FavoriteMomentsScreen> createState() => _FavoriteMomentsScreenState();
}

class _FavoriteMomentsScreenState extends State<FavoriteMomentsScreen> {
  final MemoryService _memoryService = MemoryService();
  List<Memory> _favoriteMemories = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteMemories();
  }

  Future<void> _loadFavoriteMemories() async {
    final favorites = await _memoryService.getFavoriteMemories();
    if (mounted) {
      setState(() {
        _favoriteMemories = favorites;
      });
    }
  }

  Future<void> _toggleFavorite(Memory memory) async {
    final success = await _memoryService.toggleFavorite(memory.id);
    if (success && mounted) {
      _loadFavoriteMemories();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при изменении избранного')),
      );
    }
  }

  void _viewMemoryDetails(Memory memory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок и кнопка закрытия
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        memory.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
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
                
                const SizedBox(height: 16),
                
                // Описание
                Text(
                  memory.description,
                  style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 16),
                
                // Фотографии
                if (memory.imagePaths.isNotEmpty) ...[
                  const Text(
                    'Фотографии:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: memory.imagePaths.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          height: 100,
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
                  const SizedBox(height: 16),
                ],
                
                // Кнопка убрать из избранного
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _toggleFavorite(memory);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Убрать из избранного'),
                  ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ЛЮБИМЫЕ МОМЕНТЫ',
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
      body: _favoriteMemories.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Пока нет любимых моментов',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Добавляйте сердечки к воспоминаниям',
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
              itemCount: _favoriteMemories.length,
              itemBuilder: (context, index) {
                final memory = _favoriteMemories[index];
                return _buildMemoryCard(memory);
              },
            ),
    );
  }

  Widget _buildMemoryCard(Memory memory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewMemoryDetails(memory),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и сердечко
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
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
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
              
              // Описание (только превью)
              Text(
                memory.description.length > 100 
                    ? '${memory.description.substring(0, 100)}...' 
                    : memory.description,
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
                const SizedBox(height: 8),
              ],
              
              // Подсказка для просмотра
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Нажмите для просмотра',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.visibility,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
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