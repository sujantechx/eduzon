import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../data/models/chapter_model.dart';
import '../../data/models/pdf_model.dart';
import '../../data/models/subject_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_chapters_page.dart';
import '../../presentation/screens/admin/admin_content_page.dart';
import '../../presentation/screens/admin/admin_subjects_page.dart';
import '../../presentation/screens/admin/manage_students_screen.dart';
import '../../presentation/screens/auth/approval_pending_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/student_dashboard_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/student/chapter_pdf.dart';
import '../../presentation/screens/student/chapters_list_screen.dart';
import '../../presentation/screens/student/pdf_list_screen.dart';
import '../../presentation/screens/student/pdf_vewer_screen.dart';
import '../../presentation/screens/student/subject_pdf.dart';
import '../../presentation/screens/student/subjects_list_screen.dart';
import '../../presentation/screens/student/video_list_screen.dart';
import '../../presentation/widgets/video_player_widget.dart';
import '../enums/screen_mode.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthCubit authCubit;
  late final GoRouter router;

  AppRouter({required this.authCubit}) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
        GoRoute(path: AppRoutes.pendingApproval, builder: (context, state) => const PendingApprovalScreen()),
        GoRoute(path: AppRoutes.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: AppRoutes.manageStudents, builder: (context, state) => const ManageStudentsScreen()),
        GoRoute(path: AppRoutes.AdminSubjects, builder: (context, state) => const AdminSubjectsPage()),
        GoRoute(
          path: AppRoutes.adminContent, // Make sure this matches your AppRoutes file
          builder: (context, state) {
            // 1. Cast the 'extra' data to the expected Map type
            final data = state.extra as Map<String, dynamic>;

            // 2. Extract the subject and chapter from the map
            final subject = data['subject'] as SubjectModel;
            final chapter = data['chapter'] as ChapterModel;

            // 3. Pass the extracted data to the page widget
            return AdminContentPage(subject: subject, chapter: chapter);
          },
        ),
        GoRoute(
          path: AppRoutes.AdminChapters,
          builder: (context, state) {
            final subject = state.extra as SubjectModel;
            return AdminChaptersPage(subject: subject);
          },
        ),
        GoRoute(
          path: AppRoutes.chaptersList,
          builder: (context, state) {
            final subject = state.extra as SubjectModel;
            return ChaptersListScreen(subject: subject);
          },
        ), GoRoute(
          path: AppRoutes.chapterPDF,
          builder: (context, state) {
            final subject = state.extra as SubjectModel;
            return ChapterPdf(subject: subject);
          },
        ),
        GoRoute(
          path: AppRoutes.pdfList,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            final subject = data['subject'] as SubjectModel;
            final chapter = data['chapter'] as ChapterModel;
            return PdfListScreen(subject: subject, chapter: chapter);
          },
        ),
        // GoRoute(path: AppRoutes.pdfViewer, builder: (context, state){
        //   final url = state.pathParameters['url']!;
        //   return PdfViewerScreen(url: url);
        // }),
        GoRoute(
          path: AppRoutes.videosList,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            final subject = data['subject'] as SubjectModel;
            final chapter = data['chapter'] as ChapterModel;
            return VideosListScreen(subject: subject, chapter: chapter);
          },
        ),
        // STUDENT route for the video player
        GoRoute(
          path: '${AppRoutes.videoPlayer}/:videoId',
          builder: (context, state) {
            final videoId = state.pathParameters['videoId']!;
            return VideoPlayerScreen(
              videoId: videoId,
              mode: ScreenMode.student, // Always student mode
            );
          },
        ),

// ADMIN route for the video player preview
        GoRoute(
          path: '${AppRoutes.adminVideoPlayer}/:videoId',
          builder: (context, state) {
            final videoId = state.pathParameters['videoId']!;
            return VideoPlayerScreen(
              videoId: videoId,
              mode: ScreenMode.admin, // Always admin mode
            );
          },
        ),

// STUDENT route for the PDF viewer - CORRECTED
        // STUDENT route for the PDF viewer
        GoRoute(path: AppRoutes.pdfViewer, builder: (context, state){
          final url = state.pathParameters['url']!;
          return PdfViewerScreen(url: url);
        }),
        GoRoute(
          path: '${AppRoutes.pdfViewer}/:url',
          builder: (context, state) {
            final url = state.pathParameters['url']!;
            return PdfViewerScreen(url: url); // Added route for PdfViewerScreen
          },
        ),
        // ADMIN route for the PDF viewer preview

        GoRoute(path: AppRoutes.adminPdfViewer, builder: (context, state){
          final url = state.pathParameters['url']!;
          return PdfViewerScreen(url: url);
        }),
        GoRoute(
          path: '${AppRoutes.adminPdfViewer}/:url',
          builder: (context, state) {
            final url = state.pathParameters['url']!;
            return PdfViewerScreen(url: url); // Added route for PdfViewerScreen
          },
        ),

        // GoRoute(
        //   path: AppRoutes.adminPdfViewer,
        //   builder: (context, state) {
        //     final pdfModel = state.extra as PdfModel;
        //     return PdfViewerScreen(url: pdfModel.url);
        //   },
        // ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return DashboardShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: AppRoutes.subjectsList, builder: (context, state) => const SubjectsListScreen()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: AppRoutes.subjectPDF, builder: (context, state) => const SubjectPdf()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final authState = authCubit.state;
        final currentLocation = state.matchedLocation;
        developer.log('Redirect check: authState=$authState, currentLocation=$currentLocation');

        // Handle initial/loading states
        if (authState is AuthInitial || (authState is AuthLoading && currentLocation != AppRoutes.login && currentLocation != AppRoutes.register)) {
          developer.log('Redirecting to splash due to AuthInitial or AuthLoading (not on login/register)');
          return AppRoutes.splash;
        }

        // Handle authenticated state
        if (authState is Authenticated) {
          final user = authState.userModel;
          developer.log('Authenticated user: role=${user.role}, status=${user.status}, uid=${user.uid}');

          if (user.role == 'admin') {
            final isTryingToAccessStudentShell =
                currentLocation.startsWith(AppRoutes.subjectsList) ||
                    currentLocation.startsWith(AppRoutes.subjectPDF) ||
                    currentLocation.startsWith(AppRoutes.profile) ||
                    currentLocation.startsWith(AppRoutes.chaptersList) ||
                    currentLocation.startsWith(AppRoutes.videosList) ||
                    currentLocation.startsWith(AppRoutes.videoPlayer) ||
                    currentLocation.startsWith(AppRoutes.subjectPDF); // Added notes to admin restrictions
            final isOnAuthRoute = currentLocation == AppRoutes.login ||
                currentLocation == AppRoutes.register ||
                currentLocation == AppRoutes.splash ||
                currentLocation == AppRoutes.pendingApproval;

            if (isTryingToAccessStudentShell || isOnAuthRoute) {
              developer.log('Redirecting admin to adminDashboard');
              return AppRoutes.adminDashboard;
            }
          } else {
            final isTryingToAccessAdminRoute =
                currentLocation.startsWith(AppRoutes.adminDashboard) ||
                    currentLocation.startsWith(AppRoutes.manageStudents) ||
                    currentLocation.startsWith(AppRoutes.adminContent) ||
                    currentLocation.startsWith(AppRoutes.AdminChapters);

            if (isTryingToAccessAdminRoute) {
              developer.log('Redirecting student to subjectsList');
              return AppRoutes.subjectsList;
            }

            if (user.status == 'approved' || user.status == 'approve') {
              if (currentLocation == AppRoutes.login ||
                  currentLocation == AppRoutes.register ||
                  currentLocation == AppRoutes.splash ||
                  currentLocation == AppRoutes.pendingApproval) {
                developer.log('Redirecting approved student to subjectsList');
                return AppRoutes.subjectsList;
              }
            } else {
              if (currentLocation != AppRoutes.pendingApproval) {
                developer.log('Redirecting unapproved student to pendingApproval');
                return AppRoutes.pendingApproval;
              }
            }
          }
        } else if (authState is Unauthenticated) {
          // Handle unauthenticated state
          if (authState.pendingApproval) {
            if (currentLocation != AppRoutes.pendingApproval) {
              developer.log('Redirecting to pendingApproval after registration');
              return AppRoutes.pendingApproval;
            }
          } else {
            final isAuthRoute = currentLocation == AppRoutes.login ||
                currentLocation == AppRoutes.register ||
                currentLocation == AppRoutes.splash;
            if (!isAuthRoute) {
              developer.log('Redirecting unauthenticated user to login');
              return AppRoutes.login;
            }
          }
        } else if (authState is AuthError) {
          // Handle AuthError for registration or unapproved accounts
          if (authState.message.contains('Registration successful') || authState.message.contains('Account not approved')) {
            if (currentLocation != AppRoutes.pendingApproval) {
              developer.log('Redirecting to pendingApproval due to registration or unapproved account');
              return AppRoutes.pendingApproval;
            }
          } else {
            developer.log('AuthError state: ${authState.message}, staying on current route');
            return null;
          }
        }

        developer.log('No redirect needed');
        return null;
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      developer.log('AuthCubit stream event: $event');
      notifyListeners();
    });
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

