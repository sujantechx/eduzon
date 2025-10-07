import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/logic/Courses/courses_cubit.dart';
import 'package:eduzon/logic/test/quiz_cubit.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import 'core/routes/app_router.dart';
import 'core/theme/theme_manager.dart';
import 'firebase_options.dart';
import 'logic/auth/admin_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/test/question_cubit.dart';
import 'logic/theme/theme_cubit.dart';
import 'logic/theme/theme_state.dart'; // Added import for ContentRepository required by ContentCubit

// Main entry point for the Student Zone app
// Main entry point for the Student Zone app
const String courseIdToAdd = "e4jxWFBp4j2aHELYj8qX"; // <-- IMPORTANT: Change this value

Future<void> addCourseIdToAllUsers() async {
  // 1. Get a reference to your Firestore database and the users collection
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection('users');

  try {
    // 2. Fetch all documents from the users collection
    QuerySnapshot querySnapshot = await users.get();
    print("Found ${querySnapshot.docs.length} users to update.");

    // 3. Create a WriteBatch
    WriteBatch batch = firestore.batch();

    // 4. Iterate through each user document and add the update to the batch
    for (var doc in querySnapshot.docs) {
      // Get the reference to the specific user document
      DocumentReference userRef = users.doc(doc.id);

      // Add the update operation to the batch
      // This will add the 'coursesId' field. If the field already exists, it will be overwritten.
      batch.update(userRef, {'coursesId': courseIdToAdd});
    }

    // 5. Commit the batch to apply all the updates at once
    await batch.commit();

    print("Successfully added course ID to all users.");

  } catch (e) {
    print("An error occurred: $e");
  }
}
Future<void> removeCourseFromUser(String userId) async {
  try {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the document to remove the 'coursesId' field
    await userDoc.update({
      'coursesId': FieldValue.delete(),
    });

    print('coursesId field removed from user $userId.');
  } catch (e) {
    print('Error updating user: $e');
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // ✅ CORRECTED THIS LINE
    // Use the auto-generated DefaultFirebaseOptions for the current platform (Android/iOS).
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    developer.log('Firebase initialized successfully');

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
      );
      developer.log('Firebase App Check activated');
    } catch (e) {
      developer.log('Error activating App Check: $e', error: e);
    }
    // addCourseIdToAllUsers(); // Call the function to add courseId to all users
    removeCourseFromUser("e4jxWFBp4j2aHELYj8qX"); // Call the function to remove courseId from a specific user
    runApp(const MyApp());
  } catch (e) {
    developer.log('Error initializing app: $e', error: e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // These initializations are correct
    final authRepository = AuthRepository(
      deviceInfo: DeviceInfoPlugin(),
      uuid: const Uuid(),
    );

    final authCubit = AuthCubit(authRepository: authRepository);
    final adminCubit = AdminCubit(authRepository: authRepository);
    final testCubit = CoursesCubit(adminRepository: AdminRepository());
    final themeCubit = ThemeCubit();

    return MultiProvider(
      providers: [
        // Keep your existing providers
        Provider<AuthRepository>.value(value: authRepository),
        BlocProvider(create: (context) => authCubit..init()),
        BlocProvider(create: (context) => adminCubit),
        BlocProvider(create: (context) => themeCubit),
        BlocProvider(create: (context)=>testCubit),
        // ✅ 3. Provide the AdminRepository that CoursesCubit depends on.
        Provider<AdminRepository>(
          create: (_) => AdminRepository(),
        ),
        // ✅ 4. Now, your CoursesCubit can be created successfully
        // because it can find and read the AdminRepository provided above.
        BlocProvider<CoursesCubit>(
          create: (context) => CoursesCubit(
            adminRepository: context.read<AdminRepository>(),
          ),
        ),
        BlocProvider<QuestionCubit>(
          create: (context) => QuestionCubit(
            context.read<AdminRepository>(),
          ),
        ),
        BlocProvider<QuizCubit>(
          create: (context) => QuizCubit(
            context.read<AdminRepository>()
            , context.read<AuthCubit>(),
        ),)


      ],


      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Student Zone',
            theme: ThemeManager.light,
            darkTheme: ThemeManager.dark,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter(authCubit: authCubit).router,
          );
        },
      ),
    );
  }
}

/// crash test
/*

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: MyTestPage(),
   );

  }
}

class MyTestPage extends StatelessWidget {
  const MyTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crashlytics Test'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            // ✅ ADD THE CRASH COMMAND HERE
            FirebaseCrashlytics.instance.crash();
          },
          child: const Text('Force a Test Crash'),
        ),
      ),
    );
  }
}*/
