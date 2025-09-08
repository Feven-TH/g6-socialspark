import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One shared shell for the whole app.
/// Tabs: 0=Home, 1=Library, 2=Create, 3=Settings
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showBottomNav = true,
  });

  final Widget child;
  final int currentIndex;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    final idx = currentIndex.clamp(0, 3);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: showBottomNav
          ? BottomAppBar(
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _tab(context, 0, idx, Icons.home_outlined, 'Home', '/home'),
                    _tab(context, 1, idx, Icons.auto_awesome_mosaic_outlined, 'Library', '/library'),
                    _tab(context, 2, idx, Icons.edit_outlined, 'Create', '/create'),
                    _tab(context, 3, idx, Icons.settings_outlined, 'Settings', '/settings'),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _tab(
    BuildContext context,
    int tabIndex,
    int selectedIndex,
    IconData icon,
    String label,
    String route,
  ) {
    final selected = tabIndex == selectedIndex;
    final color = selected ? const Color(0xFF0F2137) : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
