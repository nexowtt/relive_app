// lib/models/memory.dart
class Memory {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final List<String> imagePaths;
  final bool isFavorite;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imagePaths,
    required this.isFavorite,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'imagePaths': imagePaths,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      imagePaths: List<String>.from(json['imagePaths']),
      isFavorite: json['isFavorite'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Memory copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    List<String>? imagePaths,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imagePaths: imagePaths ?? this.imagePaths,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}