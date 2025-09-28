// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This is the shell UI for the student dashboard. It's a stateless widget
// because GoRouter's StatefulShellRoute manages the state for us.
class DashboardShell extends StatelessWidget {
  // The navigationShell is provided by GoRouter. It contains the widget for the
  // current branch (tab) and the logic to switch between branches.
  final StatefulNavigationShell navigationShell;

  const DashboardShell({
    super.key,
    required this.navigationShell,
  });

  // This private method calls the goBranch method on the navigationShell
  // to switch to the selected tab.
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // This is important: if the user taps the active tab again,
      // it will reset the navigation stack for that tab.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body of the scaffold is simply the navigationShell widget itself.
      // GoRouter decides which screen to show here (Subjects, Notes, or Profile).
      body: navigationShell,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // The current index is taken directly from the navigationShell.
        currentIndex: navigationShell.currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Subjects', // Label updated to reflect the content
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        // The onTap callback uses our method to navigate branches.
        onTap: _onTap,
      ),
    );
  }
}