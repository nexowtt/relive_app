class TimeCapsule {
  String id;
  String title;
  String message;
  DateTime creationDate;
  DateTime openDate;
  bool isOpened;
  String? openedDate;

  TimeCapsule({
    required this.id,
    required this.title,
    required this.message,
    required this.creationDate,
    required this.openDate,
    this.isOpened = false,
    this.openedDate,
  });

  // Проверяет, можно ли открыть капсулу
  bool get canBeOpened {
    return DateTime.now().isAfter(openDate) || DateTime.now().isAtSameMomentAs(openDate);
  }

  // Конвертация в Map для хранения
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'openDate': openDate.millisecondsSinceEpoch,
      'isOpened': isOpened,
      'openedDate': openedDate,
    };
  }

  // Создание из Map
  factory TimeCapsule.fromMap(Map<String, dynamic> map) {
    return TimeCapsule(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate']),
      openDate: DateTime.fromMillisecondsSinceEpoch(map['openDate']),
      isOpened: map['isOpened'],
      openedDate: map['openedDate'],
    );
  }
}