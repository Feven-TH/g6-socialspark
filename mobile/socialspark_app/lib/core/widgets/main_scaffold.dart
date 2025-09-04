import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final bool showBottomNav;

  const MainScaffold({
    Key? key,
    required this.child,
    this.currentIndex = 0,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    // This setState is to optimistically update the UI.
    // The actual page change is handled by GoRouter.
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/library');
        break;
      case 2:
        // This is the FAB, which has its own onPressed.
        break;
      case 3:
        context.go('/scheduler');
        break;
      case 4:
        context.go('/home/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: widget.showBottomNav
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_filled, "Home", 0),
                    _buildNavItem(Icons.collections_bookmark, "Library", 1),
                    const SizedBox(width: 40), // Space for FAB
                    _buildNavItem(Icons.calendar_today, "Scheduler", 3),
                    _buildNavItem(Icons.settings, "Settings", 4),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: widget.showBottomNav
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implement Create Post flow
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Create new post coming soon!")),
                );
              },
              backgroundColor: const Color(0xFF0F2137),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: widget.showBottomNav
          ? FloatingActionButtonLocation.centerDocked
          : null,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0F2137) : Colors.black54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0F2137) : Colors.black54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
