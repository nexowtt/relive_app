import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_capsule.dart';

class TimeCapsuleService {
  static const String _capsulesKey = 'time_capsules';

  // Получить все капсулы
  Future<List<TimeCapsule>> getCapsules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final capsulesJson = prefs.getStringList(_capsulesKey) ?? [];
      
      return capsulesJson.map((json) {
        try {
          final map = jsonDecode(json);
          return TimeCapsule.fromMap(map);
        } catch (e) {
          print('Error parsing capsule JSON: $e');
          return _createDefaultCapsule();
        }
      }).toList();
    } catch (e) {
      print('Error getting capsules: $e');
      return [];
    }
  }

  // Сохранить капсулу
  Future<bool> saveCapsule(TimeCapsule capsule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final capsules = await getCapsules();
      
      // Удаляем старую капсулу с таким же ID (если есть)
      capsules.removeWhere((c) => c.id == capsule.id);
      
      // Добавляем новую
      capsules.add(capsule);
      
      // Сохраняем
      final capsulesJson = capsules.map((c) => jsonEncode(c.toMap())).toList();
      return await prefs.setStringList(_capsulesKey, capsulesJson);
    } catch (e) {
      print('Error saving capsule: $e');
      return false;
    }
  }

  // Удалить капсулу
  Future<bool> deleteCapsule(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final capsules = await getCapsules();
      
      capsules.removeWhere((capsule) => capsule.id == id);
      
      final capsulesJson = capsules.map((c) => jsonEncode(c.toMap())).toList();
      return await prefs.setStringList(_capsulesKey, capsulesJson);
    } catch (e) {
      print('Error deleting capsule: $e');
      return false;
    }
  }

  // Открыть капсулу
  Future<bool> openCapsule(String id) async {
    try {
      final capsules = await getCapsules();
      final capsuleIndex = capsules.indexWhere((c) => c.id == id);
      
      if (capsuleIndex != -1 && capsules[capsuleIndex].canBeOpened) {
        capsules[capsuleIndex].isOpened = true;
        capsules[capsuleIndex].openedDate = DateTime.now().toIso8601String();
        return await saveCapsule(capsules[capsuleIndex]);
      }
      return false;
    } catch (e) {
      print('Error opening capsule: $e');
      return false;
    }
  }

  // Получить капсулы, готовые к открытию
  Future<List<TimeCapsule>> getReadyToOpenCapsules() async {
    try {
      final capsules = await getCapsules();
      return capsules.where((capsule) => capsule.canBeOpened && !capsule.isOpened).toList();
    } catch (e) {
      print('Error getting ready capsules: $e');
      return [];
    }
  }

  // Получить открытые капсулы
  Future<List<TimeCapsule>> getOpenedCapsules() async {
    try {
      final capsules = await getCapsules();
      return capsules.where((capsule) => capsule.isOpened).toList();
    } catch (e) {
      print('Error getting opened capsules: $e');
      return [];
    }
  }

  // Создать капсулу по умолчанию при ошибке парсинга
  TimeCapsule _createDefaultCapsule() {
    return TimeCapsule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Капсула времени',
      message: 'Сообщение для будущего',
      creationDate: DateTime.now(),
      openDate: DateTime.now().add(const Duration(days: 365)),
    );
  }
}