// time_capsule_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/time_capsule.dart';

class TimeCapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем коллекцию капсул текущего пользователя
  CollectionReference _getUserCapsulesCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }
    return _firestore.collection('users').doc(userId).collection('time_capsules');
  }

  // Получаем ID текущего пользователя
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Получаем все капсулы пользователя
  Future<List<TimeCapsule>> getCapsules() async {
    try {
      final querySnapshot = await _getUserCapsulesCollection()
          .orderBy('openDate', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Ошибка загрузки капсул из Firebase: $e');
      return [];
    }
  }

  // Получаем избранные капсулы
  Future<List<TimeCapsule>> getFavoriteCapsules() async {
    try {
      final querySnapshot = await _getUserCapsulesCollection()
          .where('isFavorite', isEqualTo: true)
          .orderBy('openDate', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Ошибка при получении избранных капсул: $e');
      return [];
    }
  }

  // Сохраняем капсулу (создание или обновление)
  Future<bool> saveCapsule(TimeCapsule capsule) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('Пользователь не авторизован');
        return false;
      }

      final capsuleData = capsule.toFirebaseMap();
      capsuleData['userId'] = userId;
      capsuleData['updatedAt'] = FieldValue.serverTimestamp();

      if (capsule.id.isEmpty) {
        // Создаем новую капсулу
        capsuleData['createdAt'] = FieldValue.serverTimestamp();
        await _getUserCapsulesCollection().add(capsuleData);
        debugPrint('Капсула создана для пользователя ${_auth.currentUser?.email}');
      } else {
        // Обновляем существующую
        await _getUserCapsulesCollection().doc(capsule.id).update(capsuleData);
        debugPrint('Капсула обновлена');
      }
      
      return true;
    } catch (e) {
      debugPrint('Ошибка сохранения капсулы в Firebase: $e');
      return false;
    }
  }

  // Удаляем капсулу
  Future<bool> deleteCapsule(String id) async {
    try {
      await _getUserCapsulesCollection().doc(id).delete();
      debugPrint('Капсула удалена');
      return true;
    } catch (e) {
      debugPrint('Ошибка удаления капсулы из Firebase: $e');
      return false;
    }
  }

  // Открываем капсулу
  Future<bool> openCapsule(String id) async {
    try {
      final docRef = _getUserCapsulesCollection().doc(id);
      final doc = await docRef.get();
      
      if (doc.exists) {
        final capsule = TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
        
        // Проверяем, можно ли открыть капсулу
        if (capsule.canBeOpened && !capsule.isOpened) {
          await docRef.update({
            'isOpened': true,
            'openedDate': DateTime.now().toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('Капсула открыта');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Ошибка открытия капсулы: $e');
      return false;
    }
  }

  // Переключаем избранное
  Future<bool> toggleFavorite(String id) async {
    try {
      final docRef = _getUserCapsulesCollection().doc(id);
      final doc = await docRef.get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final currentValue = data?['isFavorite'] ?? false;
        
        await docRef.update({
          'isFavorite': !currentValue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        debugPrint('Избранное переключено для капсулы $id: ${!currentValue}');
        return true;
      }
      
      debugPrint('Капсула с ID $id не найдена');
      return false;
    } catch (e) {
      debugPrint('Ошибка при переключении избранного: $e');
      return false;
    }
  }

  // Получаем Stream для реального времени
  Stream<List<TimeCapsule>> get capsulesStream {
    return _getUserCapsulesCollection()
        .orderBy('openDate', descending: false)
        .snapshots()
        .handleError((error) {
          debugPrint('Ошибка в capsulesStream: $error');
          return Stream.empty();
        })
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Stream для избранных капсул
  Stream<List<TimeCapsule>> get favoriteCapsulesStream {
    return _getUserCapsulesCollection()
        .where('isFavorite', isEqualTo: true)
        .orderBy('openDate', descending: false)
        .snapshots()
        .handleError((error) {
          debugPrint('Ошибка в favoriteCapsulesStream: $error');
          return Stream.empty();
        })
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Получаем капсулы, готовые к открытию
  Future<List<TimeCapsule>> getReadyToOpenCapsules() async {
    try {
      final querySnapshot = await _getUserCapsulesCollection()
          .where('isOpened', isEqualTo: false)
          .where('openDate', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('openDate', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Ошибка получения готовых капсул: $e');
      return [];
    }
  }

  // Получаем открытые капсулы
  Future<List<TimeCapsule>> getOpenedCapsules() async {
    try {
      final querySnapshot = await _getUserCapsulesCollection()
          .where('isOpened', isEqualTo: true)
          .orderBy('openedDate', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Ошибка получения открытых капсул: $e');
      return [];
    }
  }

  // Получаем ближайшую капсулу к открытию
  Future<TimeCapsule?> getNearestCapsule() async {
    try {
      final querySnapshot = await _getUserCapsulesCollection()
          .where('isOpened', isEqualTo: false)
          .orderBy('openDate', descending: false)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return TimeCapsule.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Ошибка получения ближайшей капсулы: $e');
      return null;
    }
  }

  // Получаем статистику
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final capsules = await getCapsules();
      
      return {
        'total': capsules.length,
        'favorites': capsules.where((c) => c.isFavorite).length,
        'ready': capsules.where((c) => c.canBeOpened && !c.isOpened).length,
        'opened': capsules.where((c) => c.isOpened).length,
        'unopened': capsules.where((c) => !c.isOpened).length,
        'nearestCapsule': await getNearestCapsule(),
      };
    } catch (e) {
      debugPrint('Ошибка получения статистики: $e');
      return {
        'total': 0,
        'favorites': 0,
        'ready': 0,
        'opened': 0,
        'unopened': 0,
        'nearestCapsule': null,
      };
    }
  }
}