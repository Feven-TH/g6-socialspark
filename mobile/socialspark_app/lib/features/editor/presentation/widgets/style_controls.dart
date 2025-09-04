// lib/features/editor/presentation/widgets/style_controls.dart
import 'package:flutter/material.dart';

class StyleControls extends StatelessWidget {
  final double initialFontSize;
  final ValueChanged<double> onFontSizeChanged; // <-- Add this line

  const StyleControls({
    super.key,
    required this.initialFontSize,
    required this.onFontSizeChanged, // <-- And this line
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Style',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Font Size'),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: initialFontSize,
                min: 10,
                max: 40,
                divisions: 30,
                label: initialFontSize.round().toString(),
                onChanged: onFontSizeChanged, // <-- Use the parameter here
              ),
            ),
          ],
        ),
      ],
    );
  }
}