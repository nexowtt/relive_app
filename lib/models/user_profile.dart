import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  String displayName;
  String? photoUrl;
  String? bio;
  DateTime? birthDate;
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Конвертация в Map для Firebase
  Map<String, dynamic> toFirebaseMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'birthDate': birthDate?.toIso8601String(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Создание из Firebase Document
  factory UserProfile.fromFirebaseDoc(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      birthDate: data['birthDate'] != null 
          ? DateTime.parse(data['birthDate'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Создание нового профиля
  factory UserProfile.create({required String id, required String email}) {
    final now = DateTime.now();
    return UserProfile(
      id: id,
      email: email,
      displayName: email.split('@').first,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Копирование с изменениями
  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    DateTime? birthDate,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}