import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cek apakah Firebase sudah diinisialisasi
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD15JQa9cvOrwY0K9_FRjWk3es4i38WExg",
          appId: "1:145953908614:android:59536808bdcd0c9da92e07",
          messagingSenderId: "145953908614",
          projectId: "smart-switch-pbl-in2024-db81c",
          databaseURL: "https://smart-switch-pbl-in2024-db81c-default-rtdb.asia-southeast1.firebasedatabase.app",
          storageBucket: "smart-switch-pbl-in2024-db81c.firebasestorage.app",
        ),
      );
    }
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Switch User',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gagal memuat aplikasi'),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}