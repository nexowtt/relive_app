// services/user_profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем коллекцию профилей
  CollectionReference get _profilesCollection {
    return _firestore.collection('user_profiles');
  }

  // Получаем профиль текущего пользователя
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _profilesCollection.doc(user.uid).get();
      
      if (doc.exists) {
        return UserProfile.fromFirebaseDoc(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        // Создаем новый профиль, если не существует
        final newProfile = UserProfile.create(id: user.uid, email: user.email ?? '');
        await saveProfile(newProfile);
        return newProfile;
      }
    } catch (e) {
      debugPrint('❌ Ошибка получения профиля: $e');
      return null;
    }
  }

  // Сохраняем профиль
  Future<bool> saveProfile(UserProfile profile) async {
    try {
      await _profilesCollection.doc(profile.id).set(
        profile.toFirebaseMap(),
        SetOptions(merge: true),
      );
      debugPrint('✅ Профиль сохранен: ${profile.displayName}');
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка сохранения профиля: $e');
      return false;
    }
  }

  // Обновляем только определенные поля
  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? bio,
    DateTime? birthDate,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (bio != null) updateData['bio'] = bio;
      if (birthDate != null) updateData['birthDate'] = birthDate.toIso8601String();

      await _profilesCollection.doc(userId).update(updateData);
      debugPrint('✅ Профиль обновлен');
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка обновления профиля: $e');
      return false;
    }
  }

  // Stream для отслеживания изменений профиля в реальном времени
  Stream<UserProfile?> get currentUserProfileStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getCurrentUserProfile();
    });
  }
}