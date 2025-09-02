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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    
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
        // This is for the center FAB
        break;
      case 3:
        // Add brand page if needed
        break;
      case 4:
        // Add settings page if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: widget.showBottomNav ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.star_border, "Library", 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.palette_outlined, "Brand", 3),
              _buildNavItem(Icons.settings, "Settings", 4),
            ],
          ),
        ),
      ) : null,
      floatingActionButton: widget.showBottomNav ? FloatingActionButton(
        onPressed: () {
          // Handle FAB press
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new post')),
          );
        },
        backgroundColor: const Color(0xFF0F2137),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: widget.showBottomNav 
          ? FloatingActionButtonLocation.centerDocked 
          : null,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0F2137) : Colors.black54,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0F2137) : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
