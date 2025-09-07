import 'package:flutter/material.dart';
import 'package:socialspark_app/features/editor/domain/entities/content.dart';

class VisualPreview extends StatelessWidget {
  final Content content;

  const VisualPreview({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final previewSize = screenWidth * 0.9; // 90% of screen width for 1:1 aspect ratio

    return Container(
      width: previewSize,
      height: previewSize,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: content.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(content.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) => const Icon(Icons.error),
              )
            : null,
      ),
      child: content.imageUrl.isEmpty
          ? const Center(child: Text('No image to display.'))
          : Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Color(int.parse('FF${content.backgroundColor?.substring(1) ?? '000000'}', radix: 16)).withOpacity(0.4),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '${content.caption ?? ''}\n${content.hashtags ?? ''}',
                      style: TextStyle(
                        color: Color(int.parse('FF${content.textColor?.substring(1) ?? 'FFFFFF'}', radix: 16)),
                        fontFamily: content.fontStyle,
                        fontSize: content.fontSize ?? 16.0,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}