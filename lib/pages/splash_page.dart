// import 'package:complaint_vision/pages/home_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'auth_page.dart';

// class SplashPage extends StatefulWidget {
//   @override
//   _SplashPageState createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(seconds: 1), () async {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // Redirect to HomePage after complaints are loaded
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => HomePage()),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(  
//           MaterialPageRoute(builder: (context) => AuthPage()),
//         );
//       }
//     });
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit
//             .expand, // Ensures the background image covers the full screen
//         children: [
//           // Background Image
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(
//                     'lib/assets/images/backg.jpg'), // Replace with your image path
//                 fit: BoxFit.cover, // Makes the image cover the entire screen
//               ),
//             ),
//           ),
//           // Foreground (logo, progress indicator, and text)
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Logo or splash screen image
//                 Image.asset(
//                   'lib/assets/images/image.png',
//                   height: 150,
//                 ),
//                 SizedBox(height: 20),
//                 // Loading indicator
//                 CircularProgressIndicator(),
//                 SizedBox(height: 20),
//                 // Welcome text
//                 const Text(
//                   'Welcome to Complaint Vision App',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors
//                         .white, // Ensure text is visible on the background
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:complaint_vision/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'package:complaint_vision/services/user_info.dart'; // Import your UserInfoService


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await Future.delayed(Duration(seconds: 1)); // Simulating splash delay

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Set user info before navigating
      UserInfoService.setUserInfo(
        uid: user.uid,
        userEmail: user.email ?? '',
      );

      // Navigate to HomePage after setting user info
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Navigate to AuthPage if no user is logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/backg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground UI elements
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/image.png',
                  height: 150,
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
                SizedBox(height: 20),
                const Text(
                  'Welcome to Complaint Vision App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
