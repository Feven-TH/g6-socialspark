// lib/features/editor/presentation/widgets/hashtag_input.dart
import 'package:flutter/material.dart';

class HashtagInput extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged; // <-- Add this line

  const HashtagInput({
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
          onChanged: onChanged, // <-- Use the parameter here
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            hintText: 'Add hashtag',
            prefixIcon: const Icon(Icons.tag),
          ),
        ),
        // ... (other widgets)
      ],
    );
  }
}