import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WriteLCScreen extends StatelessWidget {
  const WriteLCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write LC'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.edit_document, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Write LC Feature Coming Soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
