import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socialspark_app/core/widgets/main_scaffold.dart';
import 'package:socialspark_app/features/scheduling/presentation/pages/scheduler_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 1, // Library is the second item (0-based index)
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Library'),
            floating: true,
            pinned: true,
            actions: [
              // Add Schedule button in the app bar
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to Scheduler page with a new post
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchedulerPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.schedule, color: Colors.white),
                  label: const Text('Schedule', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2137),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add your library content here
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Your library content will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
