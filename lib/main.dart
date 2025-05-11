import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart'; // Import Firebase App Check
import 'pages/splash_page.dart'; // Import SplashPage
import 'package:provider/provider.dart';
import 'providers/complaint_provider.dart'; // Adjust import based on your structure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase based on the platform (Web or Mobile)
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAp8ai9J8ErpPuwuQ_55i5D9fpRT-iXG5U",
        authDomain: "complaintvision-a1a54.firebaseapp.com",
        projectId: "complaintvision-a1a54",
        storageBucket: "complaintvision-a1a54.appspot.com",
        messagingSenderId: "1057035354050",
        appId: "1:1057035354050:web:5d9bfbd525825c268d605b",
      ),
    );
  } else {
    await Firebase.initializeApp();

    // Initialize Firebase App Check for mobile
    // await FirebaseAppCheck.instance.activate();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ComplaintProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Complaint Vision App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(), // Start with SplashPage
    );
  }
}
