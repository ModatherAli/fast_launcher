import 'package:flutter/material.dart';

class UrlButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  const UrlButton({super.key, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: IconButton(onPressed: onPressed, icon: Icon(icon)),
      ),
    );
  }
}
