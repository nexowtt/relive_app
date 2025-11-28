class Memory {
  String id;
  String title;
  String description;
  DateTime date;
  List<String> imagePaths;
  bool isFavorite;
  DateTime createdAt;

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imagePaths,
    this.isFavorite = false,
    required this.createdAt,
  });

  // Конвертация в Map для хранения
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'imagePaths': imagePaths,
      'isFavorite': isFavorite,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Создание из Map
  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      imagePaths: List<String>.from(map['imagePaths']),
      isFavorite: map['isFavorite'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}