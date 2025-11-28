import 'package:flutter/material.dart';
import '../models/time_capsule.dart';
import '../services/time_capsule_service.dart';
import 'add_time_capsule_screen.dart';
import 'view_time_capsule_screen.dart';

class TimeCapsuleScreen extends StatefulWidget {
  const TimeCapsuleScreen({super.key});

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  final TimeCapsuleService _capsuleService = TimeCapsuleService();
  List<TimeCapsule> _capsules = [];
  List<TimeCapsule> _readyCapsules = [];
  List<TimeCapsule> _openedCapsules = [];

  @override
  void initState() {
    super.initState();
    _loadCapsules();
  }

  Future<void> _loadCapsules() async {
    final capsules = await _capsuleService.getCapsules();
    final readyCapsules = await _capsuleService.getReadyToOpenCapsules();
    final openedCapsules = await _capsuleService.getOpenedCapsules();
    
    if (mounted) {
      setState(() {
        _capsules = capsules;
        _readyCapsules = readyCapsules;
        _openedCapsules = openedCapsules;
      });
    }
  }

  void _addNewCapsule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimeCapsuleScreen(
          onSave: _loadCapsules,
        ),
      ),
    );
  }

  void _viewCapsule(TimeCapsule capsule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTimeCapsuleScreen(
          capsule: capsule,
          onUpdate: _loadCapsules,
        ),
      ),
    );
  }

  Future<void> _openCapsule(TimeCapsule capsule) async {
    final success = await _capsuleService.openCapsule(capsule.id);
    if (success && mounted) {
      _loadCapsules();
      _viewCapsule(capsule);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть капсулу')),
      );
    }
  }

  Future<void> _deleteCapsule(TimeCapsule capsule) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить капсулу?'),
          content: Text('Вы уверены, что хотите удалить "${capsule.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      final success = await _capsuleService.deleteCapsule(capsule.id);
      if (success) {
        _loadCapsules();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при удалении')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'КАПСУЛА ВРЕМЕНИ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _capsules.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.time_to_leave_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Пока нет капсул времени',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Создайте первую капсулу для будущего',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Готовые к открытию капсулы
                if (_readyCapsules.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Готовы к открытию 🔓', _readyCapsules.length),
                  ),
                if (_readyCapsules.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final capsule = _readyCapsules[index];
                        return _buildReadyCapsuleCard(capsule);
                      },
                      childCount: _readyCapsules.length,
                    ),
                  ),

                // Открытые капсулы
                if (_openedCapsules.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Открытые капсулы 📖', _openedCapsules.length),
                  ),
                if (_openedCapsules.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final capsule = _openedCapsules[index];
                        return _buildOpenedCapsuleCard(capsule);
                      },
                      childCount: _openedCapsules.length,
                    ),
                  ),

                // Ожидающие капсулы
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Ожидающие ⏳', _capsules.where((c) => !c.canBeOpened && !c.isOpened).length),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final waitingCapsules = _capsules.where((c) => !c.canBeOpened && !c.isOpened).toList();
                      final capsule = waitingCapsules[index];
                      return _buildWaitingCapsuleCard(capsule);
                    },
                    childCount: _capsules.where((c) => !c.canBeOpened && !c.isOpened).length,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCapsule,
        backgroundColor: const Color(0xFFB79CFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFB79CFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyCapsuleCard(TimeCapsule capsule) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 4,
      color: const Color(0xFFE8F5E8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.lock_open, color: Colors.green),
        title: Text(
          capsule.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Можно открыть!'),
            Text(
              'Создана: ${_formatDate(capsule.creationDate)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.green),
          onPressed: () => _openCapsule(capsule),
        ),
        onTap: () => _openCapsule(capsule),
      ),
    );
  }

  Widget _buildOpenedCapsuleCard(TimeCapsule capsule) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.bookmark_outline, color: Colors.blue),
        title: Text(
          capsule.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Открыта: ${_formatDate(DateTime.parse(capsule.openedDate!))}'),
            Text(
              'Создана: ${_formatDate(capsule.creationDate)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blue),
          onPressed: () => _viewCapsule(capsule),
        ),
        onTap: () => _viewCapsule(capsule),
      ),
    );
  }

  Widget _buildWaitingCapsuleCard(TimeCapsule capsule) {
    final daysLeft = capsule.openDate.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.lock_outline, color: Colors.orange),
        title: Text(
          capsule.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Откроется: ${_formatDate(capsule.openDate)}'),
            Text(
              'Осталось дней: $daysLeft',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined, color: Colors.grey),
              onPressed: () => _viewCapsule(capsule),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _deleteCapsule(capsule),
            ),
          ],
        ),
        onTap: () => _viewCapsule(capsule),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}