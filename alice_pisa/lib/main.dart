import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/game_state_manager.dart';
import 'screens/splash_screen.dart';
import 'services/tts_service.dart';
import 'services/local_storage_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize local storage
  await LocalStorageService.instance.init();
  
  runApp(const AlicePisaApp());
}

class AlicePisaApp extends StatelessWidget {
  const AlicePisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateManager()),
        Provider(create: (_) => TTSService()),
      ],
      child: MaterialApp(
        title: 'Alice Pisa',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}