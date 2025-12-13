// lib/services/local_image_service.dart
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalImageService {
  // Получаем директорию для сохранения изображений
  static Future<Directory> _getMemoriesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory('${appDir.path}/memories');
    
    if (!await memoriesDir.exists()) {
      await memoriesDir.create(recursive: true);
    }
    
    return memoriesDir;
  }
  
  // Сохраняем одно изображение
  static Future<String> saveImage(File imageFile) async {
    try {
      final memoriesDir = await _getMemoriesDirectory();
      
      // Генерируем уникальное имя файла
      final random = Random();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomNum = random.nextInt(10000);
      final fileName = 'memory_${timestamp}_$randomNum.jpg';
      
      final savePath = path.join(memoriesDir.path, fileName);
      final savedFile = await imageFile.copy(savePath);
      
      print('✅ Изображение сохранено: $savePath');
      return savedFile.path;
      
    } catch (e) {
      print('❌ Ошибка сохранения изображения: $e');
      throw Exception('Не удалось сохранить изображение: $e');
    }
  }
  
  // Сохраняем несколько изображений
  static Future<List<String>> saveMultipleImages(List<File> imageFiles) async {
    final savedPaths = <String>[];
    
    for (final imageFile in imageFiles) {
      try {
        final savedPath = await saveImage(imageFile);
        savedPaths.add(savedPath);
      } catch (e) {
        print('⚠️ Пропускаем изображение из-за ошибки: $e');
      }
    }
    
    return savedPaths;
  }
  
  // Удаляем изображение
  static Future<void> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Изображение удалено: $filePath');
      }
    } catch (e) {
      print('❌ Ошибка удаления изображения: $e');
    }
  }
  
  // Проверяем существование файла
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  // Получаем размер директории с воспоминаниями
  static Future<int> getStorageSize() async {
    try {
      final memoriesDir = await _getMemoriesDirectory();
      final files = await memoriesDir.list().toList();
      
      int totalSize = 0;
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  // Очищаем все изображения (для тестирования)
  static Future<void> clearAllImages() async {
    try {
      final memoriesDir = await _getMemoriesDirectory();
      if (await memoriesDir.exists()) {
        await memoriesDir.delete(recursive: true);
        print('🧹 Все изображения удалены');
      }
    } catch (e) {
      print('❌ Ошибка очистки изображений: $e');
    }
  }
}