import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF0F2137),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTabItem(context, 0, Icons.home_outlined, 'Home', '/'),
              _buildTabItem(
                  context, 1, Icons.auto_awesome_mosaic_outlined, 'Library', '/library'),
              const SizedBox(width: 48), // The space for the FAB
              _buildTabItem(context, 2, Icons.calendar_today_outlined,
                  'Scheduler', '/scheduler-board'),
              _buildTabItem(
                  context, 3, Icons.settings_outlined, 'Settings', '/settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, IconData icon,
      String label, String route) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0F2137) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF0F2137) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
