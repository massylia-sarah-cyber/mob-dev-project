import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/auth/gateway_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'navigation/main_scaffold.dart';
import 'core/services/audio_player_service.dart';
import 'core/providers/music_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mplay.app.channel.audio',
    androidNotificationChannelName: 'Mplay Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }

  try {
    await AudioPlayerService.instance.init();
  } catch (e) {
    debugPrint('⚠️ AudioPlayerService init failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: const MplayApp(),
    ),
  );
}

class MplayApp extends StatelessWidget {
  const MplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mplay - Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/gateway',
      routes: {
        '/gateway': (context) => const GatewayScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainScaffold(),
      },
    );
  }
}
