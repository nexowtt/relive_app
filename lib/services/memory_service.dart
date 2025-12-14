// services/memory_service.dart
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/memory.dart';

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем коллекцию воспоминаний текущего пользователя
  CollectionReference _getUserMemoriesCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }
    return _firestore.collection('users').doc(userId).collection('memories');
  }

  // Получаем ID текущего пользователя
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Получаем все воспоминания пользователя
  Future<List<Memory>> getMemories() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection()
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Memory(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          imagePaths: List<String>.from(data['imagePaths'] ?? []),
          isFavorite: data['isFavorite'] ?? false,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Ошибка загрузки воспоминаний из Firebase: $e');
      return [];
    }
  }

  // Получаем избранные воспоминания
  Future<List<Memory>> getFavoriteMemories() async {
    try {
      final allMemories = await getMemories();
      return allMemories.where((memory) => memory.isFavorite).toList();
    } catch (e) {
      debugPrint('Ошибка при получении избранных воспоминаний: $e');
      return [];
    }
  }

  // Сохраняем воспоминание (создание или обновление)
  Future<bool> saveMemory(Memory memory) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ Пользователь не авторизован');
        return false;
      }

      final memoryData = {
        'title': memory.title,
        'description': memory.description,
        'date': Timestamp.fromDate(memory.date),
        'imagePaths': memory.imagePaths,
        'isFavorite': memory.isFavorite,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (memory.id.isEmpty) {
        // Создаем новое воспоминание
        memoryData['createdAt'] = FieldValue.serverTimestamp();
        await _getUserMemoriesCollection().add(memoryData);
        debugPrint('✅ Память создана для пользователя ${_auth.currentUser?.email}');
      } else {
        // Обновляем существующее
        await _getUserMemoriesCollection().doc(memory.id).update(memoryData);
        debugPrint('✅ Память обновлена');
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка сохранения памяти в Firebase: $e');
      return false;
    }
  }

  // Удаляем воспоминание
  Future<bool> deleteMemory(String id) async {
    try {
      await _getUserMemoriesCollection().doc(id).delete();
      debugPrint('✅ Память удалена');
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка удаления памяти из Firebase: $e');
      return false;
    }
  }

  // Переключаем избранное
  Future<bool> toggleFavorite(String id) async {
    try {
      // Получаем документ
      final docRef = _getUserMemoriesCollection().doc(id);
      final doc = await docRef.get();
      
      if (doc.exists) {
        // Явно приводим тип
        final data = doc.data() as Map<String, dynamic>?;
        final currentValue = data?['isFavorite'] ?? false;
        
        // Обновляем поле isFavorite
        await docRef.update({
          'isFavorite': !currentValue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        debugPrint('✅ Избранное переключено для документа $id: ${!currentValue}');
        return true;
      }
      
      debugPrint('❌ Документ с ID $id не найден');
      return false;
    } catch (e) {
      debugPrint('Ошибка при переключении избранного: $e');
      return false;
    }
  }
  
  // Получаем Stream для реального времени (все воспоминания)
  Stream<List<Memory>> get allMemoriesStream {
    return _getUserMemoriesCollection()
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('❌ Ошибка в allMemoriesStream: $error');
          // Возвращаем пустой стрим вместо падения
          return Stream<List<Memory>>.empty();
        })
        .map((snapshot) {
          // Всегда возвращаем список, даже если он пустой
          final List<Memory> memories = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Memory(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              imagePaths: List<String>.from(data['imagePaths'] ?? []),
              isFavorite: data['isFavorite'] ?? false,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList();
          
          debugPrint('📊 allMemoriesStream emitted ${memories.length} memories');
          return memories;
        })
        .startWith([]); // Важно: начальное значение для немедленного отображения
  }

  // Получаем Stream для избранных воспоминаний
  Stream<List<Memory>> get favoriteMemoriesStream {
    return _getUserMemoriesCollection()
        .where('isFavorite', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('❌ Ошибка в favoriteMemoriesStream: $error');
          // Возвращаем пустой стрим вместо падения
          return Stream<List<Memory>>.empty();
        })
        .map((snapshot) {
          // Всегда возвращаем список, даже если он пустой
          final List<Memory> memories = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Memory(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              imagePaths: List<String>.from(data['imagePaths'] ?? []),
              isFavorite: true, // Всегда true для этой коллекции
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList();
          
          debugPrint('❤️ favoriteMemoriesStream emitted ${memories.length} favorite memories');
          return memories;
        })
        .startWith([]); // Важно: начальное значение для немедленного отображения
  }

  // Получаем одно воспоминание по ID
  Future<Memory?> getMemoryById(String id) async {
    try {
      final doc = await _getUserMemoriesCollection().doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Memory(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          imagePaths: List<String>.from(data['imagePaths'] ?? []),
          isFavorite: data['isFavorite'] ?? false,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Ошибка получения памяти по ID: $e');
      return null;
    }
  }

  // Поиск воспоминаний по заголовку
  Stream<List<Memory>> searchMemories(String query) {
    if (query.isEmpty) {
      return allMemoriesStream;
    }
    
    return _getUserMemoriesCollection()
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('❌ Ошибка в searchMemories: $error');
          return Stream<List<Memory>>.empty();
        })
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Memory(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              imagePaths: List<String>.from(data['imagePaths'] ?? []),
              isFavorite: data['isFavorite'] ?? false,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList();
        })
        .startWith([]);
  }

  // Получаем воспоминания по месяцу и году
  Stream<List<Memory>> getMemoriesByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = month < 12 
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    
    return _getUserMemoriesCollection()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('❌ Ошибка в getMemoriesByMonth: $error');
          return Stream<List<Memory>>.empty();
        })
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Memory(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              imagePaths: List<String>.from(data['imagePaths'] ?? []),
              isFavorite: data['isFavorite'] ?? false,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList();
        })
        .startWith([]);
  }

  // Получаем количество воспоминаний
  Future<int> getMemoriesCount() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection().get();
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Ошибка получения количества воспоминаний: $e');
      return 0;
    }
  }

  // Получаем количество избранных воспоминаний
  Future<int> getFavoriteMemoriesCount() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection()
          .where('isFavorite', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Ошибка получения количества избранных воспоминаний: $e');
      return 0;
    }
  }

  // Проверяем, есть ли воспоминания
  Future<bool> hasMemories() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection()
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Ошибка проверки наличия воспоминаний: $e');
      return false;
    }
  }

  // Получаем последнее воспоминание
  Future<Memory?> getLastMemory() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection()
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return Memory(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          imagePaths: List<String>.from(data['imagePaths'] ?? []),
          isFavorite: data['isFavorite'] ?? false,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Ошибка получения последнего воспоминания: $e');
      return null;
    }
  }

  // Удаляем все воспоминания пользователя (для тестирования)
  Future<bool> deleteAllMemories() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection().get();
      
      // Удаляем каждый документ
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('✅ Все воспоминания удалены');
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка удаления всех воспоминаний: $e');
      return false;
    }
  }

  // Получаем статистику по воспоминаниям
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final allMemories = await getMemories();
      
      // Подсчет по годам
      final memoriesByYear = <int, int>{};
      for (final memory in allMemories) {
        final year = memory.date.year;
        memoriesByYear[year] = (memoriesByYear[year] ?? 0) + 1;
      }
      
      // Подсчет по месяцам текущего года
      final currentYear = DateTime.now().year;
      final memoriesByMonth = List<int>.filled(12, 0);
      for (final memory in allMemories) {
        if (memory.date.year == currentYear) {
          memoriesByMonth[memory.date.month - 1]++;
        }
      }
      
      return {
        'total': allMemories.length,
        'favorites': allMemories.where((m) => m.isFavorite).length,
        'withImages': allMemories.where((m) => m.imagePaths.isNotEmpty).length,
        'memoriesByYear': memoriesByYear,
        'memoriesByMonth': memoriesByMonth,
        'years': memoriesByYear.keys.toList()..sort(),
      };
    } catch (e) {
      debugPrint('❌ Ошибка получения статистики: $e');
      return {
        'total': 0,
        'favorites': 0,
        'withImages': 0,
        'memoriesByYear': {},
        'memoriesByMonth': List<int>.filled(12, 0),
        'years': [],
      };
    }
  }
}