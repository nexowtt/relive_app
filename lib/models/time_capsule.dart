// models/time_capsule.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeCapsule {
  final String id;
  final String title;
  final String message;
  final DateTime creationDate;
  final DateTime openDate;
  final bool isOpened;
  final String? openedDate;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TimeCapsule({
    required this.id,
    required this.title,
    required this.message,
    required this.creationDate,
    required this.openDate,
    this.isOpened = false,
    this.openedDate,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  // Проверяет, можно ли открыть капсулу
  bool get canBeOpened {
    return DateTime.now().isAfter(openDate) || DateTime.now().isAtSameMomentAs(openDate);
  }

  // Рассчитывает количество оставшихся дней до открытия
  int get daysUntilOpening {
    if (canBeOpened || isOpened) return 0;
    return openDate.difference(DateTime.now()).inDays;
  }

  // Получает статус капсулы
  CapsuleStatus get status {
    if (isOpened) return CapsuleStatus.opened;
    if (canBeOpened) return CapsuleStatus.ready;
    return CapsuleStatus.waiting;
  }

  // Метод для копирования с изменениями
  TimeCapsule copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? creationDate,
    DateTime? openDate,
    bool? isOpened,
    String? openedDate,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeCapsule(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      creationDate: creationDate ?? this.creationDate,
      openDate: openDate ?? this.openDate,
      isOpened: isOpened ?? this.isOpened,
      openedDate: openedDate ?? this.openedDate,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Конвертация в Map для Firebase
  Map<String, dynamic> toFirebaseMap() {
    final map = <String, dynamic>{
      'title': title,
      'message': message,
      'creationDate': Timestamp.fromDate(creationDate),
      'openDate': Timestamp.fromDate(openDate),
      'isOpened': isOpened,
      'isFavorite': isFavorite,
    };

    if (openedDate != null) {
      map['openedDate'] = openedDate;
    }

    if (createdAt != null) {
      map['createdAt'] = Timestamp.fromDate(createdAt!);
    }

    if (updatedAt != null) {
      map['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return map;
  }

  // Конвертация в Map для SharedPreferences (обратная совместимость)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'openDate': openDate.millisecondsSinceEpoch,
      'isOpened': isOpened,
      'openedDate': openedDate,
      'isFavorite': isFavorite,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Создание из Map для SharedPreferences (обратная совместимость)
  factory TimeCapsule.fromMap(Map<String, dynamic> map) {
    return TimeCapsule(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate']),
      openDate: DateTime.fromMillisecondsSinceEpoch(map['openDate']),
      isOpened: map['isOpened'] ?? false,
      openedDate: map['openedDate'],
      isFavorite: map['isFavorite'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  // Создание из Firebase Document
  factory TimeCapsule.fromFirebaseDoc(String id, Map<String, dynamic> data) {
    return TimeCapsule(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      openDate: (data['openDate'] as Timestamp).toDate(),
      isOpened: data['isOpened'] ?? false,
      openedDate: data['openedDate'],
      isFavorite: data['isFavorite'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Создание новой капсулы
  factory TimeCapsule.create({
    required String title,
    required String message,
    required DateTime openDate,
  }) {
    final now = DateTime.now();
    return TimeCapsule(
      id: '', // ID будет создан в Firebase
      title: title,
      message: message,
      creationDate: now,
      openDate: openDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'TimeCapsule(id: $id, title: $title, status: $status, canBeOpened: $canBeOpened, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TimeCapsule &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.creationDate == creationDate &&
        other.openDate == openDate &&
        other.isOpened == isOpened &&
        other.openedDate == openedDate &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        message.hashCode ^
        creationDate.hashCode ^
        openDate.hashCode ^
        isOpened.hashCode ^
        openedDate.hashCode ^
        isFavorite.hashCode;
  }
}

// Статусы капсулы времени
enum CapsuleStatus {
  waiting,  // Ожидает открытия
  ready,    // Готова к открытию
  opened,   // Уже открыта
}

// Расширение для красивого отображения статуса
extension CapsuleStatusExtension on CapsuleStatus {
  String get displayName {
    switch (this) {
      case CapsuleStatus.waiting:
        return 'Ожидает';
      case CapsuleStatus.ready:
        return 'Готова';
      case CapsuleStatus.opened:
        return 'Открыта';
    }
  }

  String get emoji {
    switch (this) {
      case CapsuleStatus.waiting:
        return '⏳';
      case CapsuleStatus.ready:
        return '🎁';
      case CapsuleStatus.opened:
        return '📖';
    }
  }

  Color get color {
    switch (this) {
      case CapsuleStatus.waiting:
        return Colors.orange;
      case CapsuleStatus.ready:
        return Colors.green;
      case CapsuleStatus.opened:
        return Colors.blue;
    }
  }
}