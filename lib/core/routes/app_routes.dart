// lib/core/routes/app_routes.dart

class AppRoutes {

  // Core & Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String pendingApproval = '/pending-approval';



  // Student-Facing Routes


  //  Student Dashboard Shell Tabs
  // These are the entry points for the bottom navigation bar.
  static const String subjectsList = '/subjects'; // The first tab and main student screen.
  static const String subjectPDF = '/subjectPDF';
  static const String profile = '/profile';

  //  Student Content Drill-Down
  // These screens are pushed on top of the shell.
  static const String chaptersList = '/chapters';
  static const String chapterPDF = '/chapterPDF';
  static const String pdfViewer = '/pdf-viewer';
  static const String pdfList = '/pdf-list';
  static const String videosList = '/videos-list';
  static const String videoPlayer = '/video-player';


  // Admin Panel Routes

  static const String adminDashboard = '/admin'; // Main dashboard for admins.
  static const String manageStudents = '/admin/manage-students';
  static const String adminContent = '/admin/manage-content';
  static const String AdminChapters = '/admin/manage-chapters';
  static const String AdminSubjects = '/admin/manage-subject';
  static const String adminVideoPlayer = '/admin/video-player';
  static const String adminPdfViewer = '/admin/pdf-viewer';
  static const String manageCourses = '/admin/manage-courses';

// static const String AdminChapters = '/admin/manage-chapters';
// We will add '/admin/manage-videos' here in the next step.
}
