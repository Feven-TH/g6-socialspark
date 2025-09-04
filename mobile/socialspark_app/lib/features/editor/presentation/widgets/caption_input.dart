// lib/features/editor/presentation/widgets/caption_input.dart
import 'package:flutter/material.dart';

class CaptionInput extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged; // <-- Add this line

  const CaptionInput({
    super.key,
    required this.initialValue,
    required this.onChanged, // <-- And this line
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... (other widgets)
        TextFormField(
          initialValue: initialValue,
          maxLines: 5,
          onChanged: onChanged, // <-- Use the parameter here
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            hintText: 'Try our new Caramel Macadamia Latte! Perfect coffee...',
          ),
        ),
        // ... (other widgets)
      ],
    );
  }
}