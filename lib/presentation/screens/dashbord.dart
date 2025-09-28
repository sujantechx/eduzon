// // lib/presentation/screens/dashboard/dashboard_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// // This is the shell UI for the student dashboard.
// // It contains the BottomNavigationBar and the body for the selected tab.
// class DashboardShell extends StatelessWidget {
//   // The navigation shell and container for the branch navigators.
//   final StatefulNavigationShell navigationShell;
//
//   const DashboardShell({
//     super.key,
//     required this.navigationShell,
//   });
//
//   // This method is called by the router to navigate to a specific tab.
//   void _onTap(BuildContext context, int index) {
//     navigationShell.goBranch(
//       index,
//       // `initialLocation: true` is important to reset the tab's navigation stack
//       // when the user clicks on the tab again if they are already on it.
//       initialLocation: index == navigationShell.currentIndex,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // The body is the widget for the current tab, provided by the navigationShell.
//       body: navigationShell,
//
//       // The BottomNavigationBar that controls the navigation.
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         // The current index is obtained from the navigationShell.
//         currentIndex: navigationShell.currentIndex,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Videos'),
//           BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: 'Notes'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//         // The onTap callback uses our method to navigate branches.
//         onTap: (index) => _onTap(context, index),
//       ),
//     );
//   }
// }