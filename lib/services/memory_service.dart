// services/memory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      print('❌ Ошибка загрузки воспоминаний из Firebase: $e');
      return [];
    }
  }

  // Получаем избранные воспоминания
  Future<List<Memory>> getFavoriteMemories() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection()
          .where('isFavorite', isEqualTo: true)
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
          isFavorite: true,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('❌ Ошибка загрузки избранных воспоминаний: $e');
      return [];
    }
  }

  // Сохраняем воспоминание (создание или обновление)
  Future<bool> saveMemory(Memory memory) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('❌ Пользователь не авторизован');
        return false;
      }

      final memoryData = {
        'title': memory.title,
        'description': memory.description,
        'date': Timestamp.fromDate(memory.date),
        'imagePaths': memory.imagePaths, // URL изображений из Firebase Storage
        'isFavorite': memory.isFavorite,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (memory.id.isEmpty) {
        // Создаем новое воспоминание
        memoryData['createdAt'] = FieldValue.serverTimestamp();
        await _getUserMemoriesCollection().add(memoryData);
        print('✅ Память создана для пользователя ${_auth.currentUser?.email}');
      } else {
        // Обновляем существующее
        await _getUserMemoriesCollection().doc(memory.id).update(memoryData);
        print('✅ Память обновлена');
      }
      
      return true;
    } catch (e) {
      print('❌ Ошибка сохранения памяти в Firebase: $e');
      return false;
    }
  }

  // Удаляем воспоминание
  Future<bool> deleteMemory(String id) async {
    try {
      await _getUserMemoriesCollection().doc(id).delete();
      print('✅ Память удалена');
      return true;
    } catch (e) {
      print('❌ Ошибка удаления памяти из Firebase: $e');
      return false;
    }
  }

  // Переключаем избранное
  // Переключаем избранное
Future<bool> toggleFavorite(String id) async {
  try {
    final memoryRef = _getUserMemoriesCollection().doc(id);
    final memoryDoc = await memoryRef.get();
    
    if (memoryDoc.exists) {
      final data = memoryDoc.data();
      
      // Проверяем и преобразуем тип данных
      if (data != null && data is Map<String, dynamic>) {
        final currentFavorite = data['isFavorite'] ?? false;
        
        await memoryRef.update({
          'isFavorite': !currentFavorite,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Статус избранного изменен');
        return true;
      }
    }
    return false;
  } catch (e) {
    print('❌ Ошибка изменения избранного в Firebase: $e');
    return false;
  }
}
  // Получаем Stream для реального времени (все воспоминания)
  Stream<List<Memory>> get memoriesStream {
    return _getUserMemoriesCollection()
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Ошибка в memoriesStream: $error');
          return Stream.empty();
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
    });
  }

  // Получаем Stream для избранных воспоминаний
  Stream<List<Memory>> get favoriteMemoriesStream {
    return _getUserMemoriesCollection()
        .where('isFavorite', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Ошибка в favoriteMemoriesStream: $error');
          return Stream.empty();
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
          isFavorite: true,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
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
      print('❌ Ошибка получения памяти по ID: $e');
      return null;
    }
  }

  // Поиск воспоминаний по заголовку
  Stream<List<Memory>> searchMemories(String query) {
    if (query.isEmpty) {
      return memoriesStream;
    }
    
    return _getUserMemoriesCollection()
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Ошибка в searchMemories: $error');
          return Stream.empty();
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
    });
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
          print('❌ Ошибка в getMemoriesByMonth: $error');
          return Stream.empty();
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
    });
  }

  // Получаем количество воспоминаний
  Future<int> getMemoriesCount() async {
    try {
      final querySnapshot = await _getUserMemoriesCollection().get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('❌ Ошибка получения количества воспоминаний: $e');
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
      print('❌ Ошибка получения количества избранных воспоминаний: $e');
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
      print('❌ Ошибка проверки наличия воспоминаний: $e');
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
      print('❌ Ошибка получения последнего воспоминания: $e');
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
      
      print('✅ Все воспоминания удалены');
      return true;
    } catch (e) {
      print('❌ Ошибка удаления всех воспоминаний: $e');
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
      print('❌ Ошибка получения статистики: $e');
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