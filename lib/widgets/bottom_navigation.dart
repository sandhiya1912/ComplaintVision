//bottom_naviagtion.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import camera package
import 'package:complaint_vision/pages/gps_camera.dart'; // Import your GPS Camera page

class BottomNavigation extends StatelessWidget {
  final CameraDescription? camera; // Make camera nullable

  // Constructor allows camera to be passed or be null
  BottomNavigation({Key? key, this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Set a reasonable height for the bottom navigation bar
      color:  const Color.fromARGB(255, 242, 255, 238), // Set background color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // V-bot section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // Handle V-bot action
                },
                icon: const Icon(
                  Icons.chat,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 30, // Adjusted size for better visibility
                ),
              ),
              const Text('V-bot', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ],
          ),
          // Posts section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // Handle create post action
                },
                icon: const Icon(
                  Icons.add_circle,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 30, // Adjusted size for better visibility
                ),
              ),
              const Text('Posts', style:  TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ],
          ),
          // Feedback section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // Handle feedback action
                },
                icon: const Icon(
                  Icons.feedback,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 30, // Adjusted size for better visibility
                ),
              ),
              const Text('Feedback', style:  TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ],
          ),
          // Camera section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  if (camera != null) {
                    // Navigate to the GPS Camera page if camera is not null
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GpsCameraPage(camera: camera!),
                      ),
                    );
                  } else {
                    // Handle the case when camera is null
                    print("Camera not available");
                  }
                },
                icon: const Icon(
                  Icons.camera_alt,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 30, // Adjusted size for better visibility
                ),
              ),
              const Text('Camera', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ],
          ),
        ],
      ),
    );
  }
}
