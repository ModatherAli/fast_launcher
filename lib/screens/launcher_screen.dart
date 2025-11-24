import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/database_helper.dart';
import '../services/launcher_services.dart';

class LauncherScreen extends StatefulWidget {
  final String url;
  const LauncherScreen({super.key, required this.url});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        setState(() {
          _controller.text = clipboardData.text!;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to paste from clipboard')),
        );
      }
    }
  }

  Future<void> _openUrl() async {
    final fullUrl = widget.url + _controller.text;
    if (fullUrl.isNotEmpty) {
      // Save to history
      await DatabaseHelper.instance.insertUrl(
        UrlHistory(url: fullUrl, timestamp: DateTime.now()),
      );

      // Launch URL
      LauncherServices.lunchUrl(fullUrl);

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL opened and saved to history'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Launch URL')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(width: double.infinity, height: 200),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    helperText: widget.url.isEmpty
                        ? 'Enter full URL'
                        : widget.url,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                onPressed: _pasteFromClipboard,
                icon: const Icon(Icons.paste),
                tooltip: 'Paste',
                color: Theme.of(context).colorScheme.primary,
              ),
              IconButton(
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openUrl,
            icon: const Icon(Icons.launch),
            label: const Text('Open'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
