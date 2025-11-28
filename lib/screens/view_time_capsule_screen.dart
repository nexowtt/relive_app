import 'package:flutter/material.dart';
import '../models/time_capsule.dart';
import '../services/time_capsule_service.dart';

class ViewTimeCapsuleScreen extends StatelessWidget {
  final TimeCapsule capsule;
  final Function() onUpdate;

  const ViewTimeCapsuleScreen({
    super.key,
    required this.capsule,
    required this.onUpdate,
  });

  Future<void> _openCapsule(BuildContext context) async {
    final service = TimeCapsuleService();
    final success = await service.openCapsule(capsule.id);
    
    if (success) {
      onUpdate();
      // Закрываем экран и открываем заново с обновленными данными
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewTimeCapsuleScreen(
            capsule: capsule,
            onUpdate: onUpdate,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть капсулу')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          capsule.isOpened ? 'Капсула времени' : 'Капсула времени 🔒',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              capsule.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Информация о капсуле
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Создана:',
                    value: _formatDate(capsule.creationDate),
                  ),
                  _InfoRow(
                    icon: Icons.lock_clock,
                    label: 'Откроется:',
                    value: _formatDate(capsule.openDate),
                  ),
                  if (capsule.isOpened)
                    _InfoRow(
                      icon: Icons.lock_open,
                      label: 'Открыта:',
                      value: _formatDate(DateTime.parse(capsule.openedDate!)),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Сообщение или состояние капсулы
            _buildCapsuleContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleContent(BuildContext context) {
    if (capsule.isOpened) {
      return _buildOpenedCapsuleContent();
    } else if (capsule.canBeOpened) {
      return _buildReadyToOpenContent(context);
    } else {
      return _buildWaitingContent();
    }
  }

  Widget _buildOpenedCapsuleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ваше сообщение из прошлого:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFB79CFF).withAlpha(30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB79CFF)),
          ),
          child: Text(
            capsule.message,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildReadyToOpenContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            size: 48,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Капсула готова к открытию! 🎉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Настал момент узнать, что вы написали себе в прошлом',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openCapsule(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.lock_open),
            label: const Text('Открыть капсулу'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_clock,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Капсула откроется ${_formatDate(capsule.openDate)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Осталось ждать: ${capsule.openDate.difference(DateTime.now()).inDays} дней',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}