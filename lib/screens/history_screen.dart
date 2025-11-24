import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/database_helper.dart';
import '../services/launcher_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<UrlHistory> _urlHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await DatabaseHelper.instance.getAllUrls();
    setState(() {
      _urlHistory = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteUrl(id);
    _loadHistory();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure you want to delete all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearAllHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL History'),
        actions: [
          if (_urlHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _urlHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No history yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                itemCount: _urlHistory.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final item = _urlHistory[index];
                  final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(_getIconForUrl(item.url)),
                      ),
                      title: Text(
                        item.url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        dateFormat.format(item.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.launch, size: 20),
                            onPressed: () {
                              LauncherServices.lunchUrl(item.url);
                            },
                            tooltip: 'Open URL',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _deleteItem(item.id!),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                      onTap: () {
                        LauncherServices.lunchUrl(item.url);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  IconData _getIconForUrl(String url) {
    if (url.contains('whatsapp') || url.contains('wa.me')) {
      return Icons.chat;
    } else if (url.contains('telegram') || url.contains('t.me')) {
      return Icons.send;
    } else if (url.contains('play.google.com')) {
      return Icons.shop;
    } else {
      return Icons.link;
    }
  }
}
