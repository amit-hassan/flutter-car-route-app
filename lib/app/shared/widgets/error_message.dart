import 'package:flutter/material.dart';

class FullScreenErrorMessage extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;

  const FullScreenErrorMessage({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onPressed,
    this.icon = Icons.location_off,
    this.iconColor = const Color(0xFFEF5350), // Red.shade300
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
