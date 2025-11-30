// services/memory_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';

class MemoryService {
  static const String _storageKey = 'memories';

  Future<List<Memory>> getMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getStringList(_storageKey) ?? [];
      return memoriesJson.map((json) => Memory.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Error loading memories: $e');
      return [];
    }
  }

  Future<List<Memory>> getFavoriteMemories() async {
    final memories = await getMemories();
    return memories.where((memory) => memory.isFavorite).toList();
  }

  Future<bool> saveMemory(Memory memory) async {
    try {
      final memories = await getMemories();
      final existingIndex = memories.indexWhere((m) => m.id == memory.id);
      
      if (existingIndex >= 0) {
        memories[existingIndex] = memory;
      } else {
        memories.add(memory);
      }

      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = memories.map((m) => jsonEncode(m.toJson())).toList();
      return await prefs.setStringList(_storageKey, memoriesJson);
    } catch (e) {
      print('Error saving memory: $e');
      return false;
    }
  }

  Future<bool> deleteMemory(String id) async {
    try {
      final memories = await getMemories();
      memories.removeWhere((memory) => memory.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = memories.map((m) => jsonEncode(m.toJson())).toList();
      return await prefs.setStringList(_storageKey, memoriesJson);
    } catch (e) {
      print('Error deleting memory: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final memories = await getMemories();
      final memoryIndex = memories.indexWhere((memory) => memory.id == id);
      
      if (memoryIndex >= 0) {
        final memory = memories[memoryIndex];
        final updatedMemory = memory.copyWith(isFavorite: !memory.isFavorite);
        memories[memoryIndex] = updatedMemory;
        
        final prefs = await SharedPreferences.getInstance();
        final memoriesJson = memories.map((m) => jsonEncode(m.toJson())).toList();
        return await prefs.setStringList(_storageKey, memoriesJson);
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
}