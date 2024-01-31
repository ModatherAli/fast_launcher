import 'package:flutter/material.dart';

import '../services/launcher_services.dart';

class LauncherScreen extends StatefulWidget {
  final String url;
  const LauncherScreen({super.key, required this.url});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(
            width: double.infinity,
            height: 200,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      helperText: widget.url,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10)),
                  maxLines: null,
                ),
              ),
              IconButton(
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          OutlinedButton(
              onPressed: () {
                LauncherServices.lunchUrl(widget.url + _controller.text);
              },
              child: const Text('Open')),
        ],
      ),
    );
  }
}
