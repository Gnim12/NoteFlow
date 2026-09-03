import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/note_controller.dart';
import 'providers/theme_provider.dart';
import 'services/navigation_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'views/notes/edit_note_screen.dart';
import 'views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  NotificationService.instance.onNotificationTap = _openNoteFromNotification;
  await NotificationService.instance.init();
  _handleColdStartNotification();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NoteFlowApp(),
    ),
  );
}

/// Si l'application a été lancée en tapant sur une notification (processus
/// auparavant terminé), ouvre la note concernée une fois l'écran de
/// démarrage terminé.
void _handleColdStartNotification() {
  NotificationService.instance.getLaunchDetails().then((details) {
    if (details?.didNotificationLaunchApp != true) return;

    final noteId = details!.notificationResponse?.payload;
    if (noteId == null) return;

    Future.delayed(const Duration(milliseconds: 3500), () {
      _openNoteFromNotification(noteId);
    });
  });
}

Future<void> _openNoteFromNotification(String noteId) async {
  final user = AuthController.instance.currentUser;
  if (user == null) return;

  final note = await NoteController.instance.getNoteById(noteId, user.id);
  if (note == null) return;

  NavigationService.push(EditNoteScreen(note: note));
}

class NoteFlowApp extends StatelessWidget {
  const NoteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'NoteFlow',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}
