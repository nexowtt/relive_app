import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';

class MemoryService {
  static const String _memoriesKey = 'memories';

  // Получить все воспоминания
  Future<List<Memory>> getMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_memoriesKey) ?? [];
      
      return memoriesJson.map((json) {
        try {
          final map = jsonDecode(json);
          return Memory.fromMap(map);
        } catch (e) {
          print('Error parsing memory JSON: $e');
          return _createDefaultMemory();
        }
      }).toList();
    } catch (e) {
      print('Error getting memories: $e');
      return [];
    }
  }

  // Сохранить воспоминание
  Future<bool> saveMemory(Memory memory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memories = await getMemories();
      
      // Удаляем старое воспоминание с таким же ID (если есть)
      memories.removeWhere((m) => m.id == memory.id);
      
      // Добавляем новое
      memories.add(memory);
      
      // Сохраняем
      final memoriesJson = memories.map((m) => jsonEncode(m.toMap())).toList();
      return await prefs.setStringList(_memoriesKey, memoriesJson);
    } catch (e) {
      print('Error saving memory: $e');
      return false;
    }
  }

  // Удалить воспоминание
  Future<bool> deleteMemory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memories = await getMemories();
      
      memories.removeWhere((memory) => memory.id == id);
      
      final memoriesJson = memories.map((m) => jsonEncode(m.toMap())).toList();
      return await prefs.setStringList(_memoriesKey, memoriesJson);
    } catch (e) {
      print('Error deleting memory: $e');
      return false;
    }
  }

  // Переключить избранное
  Future<bool> toggleFavorite(String id) async {
    try {
      final memories = await getMemories();
      final memoryIndex = memories.indexWhere((m) => m.id == id);
      
      if (memoryIndex != -1) {
        memories[memoryIndex].isFavorite = !memories[memoryIndex].isFavorite;
        return await saveMemory(memories[memoryIndex]);
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Получить только избранные воспоминания
  Future<List<Memory>> getFavoriteMemories() async {
    try {
      final memories = await getMemories();
      return memories.where((memory) => memory.isFavorite).toList();
    } catch (e) {
      print('Error getting favorite memories: $e');
      return [];
    }
  }

  // Создать воспоминание по умолчанию при ошибке парсинга
  Memory _createDefaultMemory() {
    return Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Воспоминание',
      description: 'Описание',
      date: DateTime.now(),
      imagePaths: [],
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }
}