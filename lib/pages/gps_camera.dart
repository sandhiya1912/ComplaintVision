// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:io'; // To handle the image file
// import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage package
// import 'package:path/path.dart' as path; // Alias the 'path' package

// class GpsCameraPage extends StatefulWidget {
//   final CameraDescription camera;

//   const GpsCameraPage({super.key, required this.camera});

//   @override
//   State<GpsCameraPage> createState() => _GpsCameraPageState();
// }

// class _GpsCameraPageState extends State<GpsCameraPage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   Position? _currentPosition;
//   bool _isLocationEnabled = false;
//   String locationDetails = "Press the button to get location details.";

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _checkPermissions();
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }

// Future<void> _checkPermissions() async {
//   final cameraStatus = await Permission.camera.request();
//   if (cameraStatus.isDenied) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Camera permission is required')),
//       );
//     }
//     return;
//   }

//   final locationStatus = await Permission.location.request();
//   if (locationStatus.isDenied) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Location permission is required')),
//       );
//     }
//     return;
//   }

//   _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!_isLocationEnabled) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enable location services')),
//       );
//     }
//     return;
//   }

//   _startLocationUpdates();
// }

//   void _startLocationUpdates() {
//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     ).listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//         fetchLocation(position.latitude, position.longitude);
//       });
//     });
//   }

// Future<void> fetchLocation(double latitude, double longitude) async {
//   final String url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1";

//   try {
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'User-Agent': 'YourAppName',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data.containsKey('address')) {
//         final address = data['address'];
//         final city = address['city'] ?? 'N/A';
//         final town = address['town'] ?? 'N/A';
//         final village = address['village'] ?? 'N/A';
//         final state = address['state'] ?? 'N/A';
//         final country = address['country'] ?? 'N/A';

//         setState(() {
//           locationDetails =
//               "City: $city\nTown: $town\nVillage: $village\nState: $state\nCountry: $country";
//         });
//       } else {
//         setState(() {
//           locationDetails = "No address found for the given coordinates.";
//         });
//       }
//     } else {
//       setState(() {
//         locationDetails =
//             "Failed to fetch location details. Status code: ${response.statusCode}";
//       });
//     }
//   } catch (e) {
//     setState(() {
//       locationDetails = "Error fetching location: $e";
//     });
//   }
// }

//   Future<void> uploadImageToFirebase(File image) async {
//   try {
//     final fileName = path.basename(image.path); // Use path.basename() instead of basename()
//     final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
//     final uploadTask = storageRef.putFile(image);

//     final snapshot = await uploadTask.whenComplete(() {});
//     final downloadUrl = await snapshot.ref.getDownloadURL();

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image uploaded successfully: $downloadUrl')),
//       );
//     }
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//     }
//   }
// }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text('GPS Camera'),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               children: [
//                 CameraPreview(_controller),
//                 SafeArea(
//                   child: Container(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8.0),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Latitude: ${_currentPosition?.latitude ?? "Waiting..."}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Longitude: ${_currentPosition?.longitude ?? "Waiting..."}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Altitude: ${_currentPosition?.altitude ?? "Waiting..."} m',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Speed: ${_currentPosition?.speed ?? "Waiting..."} m/s',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           locationDetails,
//                           style: const TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           try {
//             await _initializeControllerFuture;
//             final image = await _controller.takePicture();
//             final imageFile = File(image.path); // Convert path to File

//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Picture saved to: ${image.path}')),
//               );

//               // Upload the image to Firebase Storage
//               await uploadImageToFirebase(imageFile);
//             }
//           } catch (e) {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Error taking picture')),
//               );
//             }
//           }
//         },
//         child: const Icon(Icons.camera),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:io'; // To handle the image file
// import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage package
// import 'package:path/path.dart' as path; // Alias the 'path' package

// class GpsCameraPage extends StatefulWidget {
//   final CameraDescription camera;

//   const GpsCameraPage({super.key, required this.camera});

//   @override
//   State<GpsCameraPage> createState() => _GpsCameraPageState();
// }

// class _GpsCameraPageState extends State<GpsCameraPage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   Position? _currentPosition;
//   bool _isLocationEnabled = false;
//   String locationDetails = "Press the button to get location details.";
//   File? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _checkPermissions();
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }

//   Future<void> _checkPermissions() async {
//     final cameraStatus = await Permission.camera.request();
//     if (cameraStatus.isDenied) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Camera permission is required')),
//         );
//       }
//       return;
//     }

//     final locationStatus = await Permission.location.request();
//     if (locationStatus.isDenied) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission is required')),
//         );
//       }
//       return;
//     }

//     _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!_isLocationEnabled) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enable location services')),
//         );
//       }
//       return;
//     }

//     _startLocationUpdates();
//   }

//   void _startLocationUpdates() {
//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     ).listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//         fetchLocation(position.latitude, position.longitude);
//       });
//     });
//   }

//   Future<void> fetchLocation(double latitude, double longitude) async {
//     final String url =
//         "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1";

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'User-Agent': 'YourAppName',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data.containsKey('address')) {
//           final address = data['address'];
//           final city = address['city'] ?? 'N/A';
//           final town = address['town'] ?? 'N/A';
//           final village = address['village'] ?? 'N/A';
//           final state = address['state'] ?? 'N/A';
//           final country = address['country'] ?? 'N/A';

//           setState(() {
//             locationDetails =
//                 "City: $city\nTown: $town\nVillage: $village\nState: $state\nCountry: $country";
//           });
//         } else {
//           setState(() {
//             locationDetails = "No address found for the given coordinates.";
//           });
//         }
//       } else {
//         setState(() {
//           locationDetails =
//               "Failed to fetch location details. Status code: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         locationDetails = "Error fetching location: $e";
//       });
//     }
//   }

//   Future<void> uploadImageToFirebase(File image) async {
//     try {
//       final fileName = path.basename(image.path);
//       final storageRef =
//           FirebaseStorage.instance.ref().child('images/$fileName');
//       final uploadTask = storageRef.putFile(image);
//       final snapshot = await uploadTask.whenComplete(() {});
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image uploaded successfully: $downloadUrl')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error uploading image: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text('Capture your complaints'),
//       ),
//       body: _capturedImage == null
//           ? FutureBuilder<void>(
//               future: _initializeControllerFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return Stack(
//                     children: [
//                       CameraPreview(_controller), // This fills the screen
//                       SafeArea(
//                         child: Align(
//                           alignment: Alignment.topLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(8.0),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.5),
//                                     borderRadius: BorderRadius.circular(8.0),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Latitude: ${_currentPosition?.latitude ?? "Waiting..."}',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Longitude: ${_currentPosition?.longitude ?? "Waiting..."}',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 Text(
//                                   locationDetails,
//                                   style: const TextStyle(
//                                       color: Colors.white, fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               },
//             )
//           : Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 Image.file(_capturedImage!),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.refresh,
//                             size: 40, color: Colors.white),
//                         onPressed: () {
//                           setState(() {
//                             _capturedImage = null;
//                           });
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.check,
//                             size: 40, color: Colors.white),
//                         onPressed: () async {
//                           if (_capturedImage != null) {
//                             await uploadImageToFirebase(_capturedImage!);
//                             setState(() {
//                               _capturedImage = null;
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: _capturedImage == null
//           ? FloatingActionButton(
//               onPressed: () async {
//                 try {
//                   await _initializeControllerFuture;
//                   final image = await _controller.takePicture();
//                   setState(() {
//                     _capturedImage = File(image.path);
//                   });
//                 } catch (e) {
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Error taking picture')),
//                     );
//                   }
//                 }
//               },
//               child: const Icon(Icons.camera),
//             )
//           : null,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:io'; // To handle the image file
// import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage package
// import 'package:path/path.dart' as path; // Alias the 'path' package

// class GpsCameraPage extends StatefulWidget {
//   final CameraDescription camera;

//   const GpsCameraPage({super.key, required this.camera});

//   @override
//   State<GpsCameraPage> createState() => _GpsCameraPageState();
// }

// class _GpsCameraPageState extends State<GpsCameraPage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   Position? _currentPosition;
//   bool _isLocationEnabled = false;
//   String locationDetails = "Press the button to get location details.";
//   File? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _checkPermissions();
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }

//   Future<void> _checkPermissions() async {
//     final cameraStatus = await Permission.camera.request();
//     if (cameraStatus.isDenied) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Camera permission is required')),
//         );
//       }
//       return;
//     }

//     final locationStatus = await Permission.location.request();
//     if (locationStatus.isDenied) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission is required')),
//         );
//       }
//       return;
//     }

//     _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!_isLocationEnabled) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enable location services')),
//         );
//       }
//       return;
//     }

//     _startLocationUpdates();
//   }

//   void _startLocationUpdates() {
//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     ).listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//         fetchLocation(position.latitude, position.longitude);
//       });
//     });
//   }

//   Future<void> fetchLocation(double latitude, double longitude) async {
//     final String url =
//         "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1";

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'User-Agent': 'YourAppName',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data.containsKey('address')) {
//           final address = data['address'];
//           final city = address['city'] ?? 'N/A';
//           final town = address['town'] ?? 'N/A';
//           final village = address['village'] ?? 'N/A';
//           final state = address['state'] ?? 'N/A';
//           final country = address['country'] ?? 'N/A';

//           setState(() {
//             locationDetails =
//                 "City: $city\nTown: $town\nVillage: $village\nState: $state\nCountry: $country";
//           });
//         } else {
//           setState(() {
//             locationDetails = "No address found for the given coordinates.";
//           });
//         }
//       } else {
//         setState(() {
//           locationDetails =
//               "Failed to fetch location details. Status code: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         locationDetails = "Error fetching location: $e";
//       });
//     }
//   }

//   Future<void> uploadImageToFirebase(File image) async {
//     try {
//       final fileName = path.basename(image.path);
//       final storageRef =
//           FirebaseStorage.instance.ref().child('images/$fileName');
//       final uploadTask = storageRef.putFile(image);
//       final snapshot = await uploadTask.whenComplete(() {});
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Complaint submitted successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error uploading image: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Set a black background to avoid any white gaps.
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Capture your complaints'),
//       ),
//       body: _capturedImage == null
//           ? FutureBuilder<void>(
//               future: _initializeControllerFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return Stack(
//                     children: [
//                       // Use Positioned.fill to ensure the preview covers the full screen.
//                       Positioned.fill(
//                         child: CameraPreview(_controller),
//                       ),
//                       // Optional: display location info at the top-left corner.
//                       Positioned(
//                         top: 16,
//                         left: 16,
//                         child: Container(
//                           padding: const EdgeInsets.all(8.0),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Latitude: ${_currentPosition?.latitude ?? "Waiting..."}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Longitude: ${_currentPosition?.longitude ?? "Waiting..."}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 locationDetails,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               },
//             )
//           : Stack(
//               children: [
//                 // Display the captured image so it fills the screen.
//                 Positioned.fill(
//                   child: Image.file(
//                     _capturedImage!,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 // Bottom action buttons
//                 Positioned(
//                   bottom: 16,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Row(
//                       mainAxisSize: MainAxisSize
//                           .min, // Make the Row take only the space it needs
//                       children: [
//                         // Retake button with label
//                         Column(
//                           mainAxisSize: MainAxisSize
//                               .min, // Make the Column take only the space it needs
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   10), // Padding inside the box
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(
//                                     0.5), // Semi-transparent black background
//                                 borderRadius: BorderRadius.circular(
//                                     10), // Rounded corners
//                               ),
//                               child: IconButton(
//                                 icon: const Icon(Icons.refresh,
//                                     size: 40, color: Colors.white),
//                                 onPressed: () {
//                                   setState(() {
//                                     _capturedImage = null;
//                                   });
//                                 },
//                               ),
//                             ),
//                             const SizedBox(
//                                 height: 8), // Space between the icon and text
//                             const Text(
//                               "Retake",
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 14),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                             width: 40), // Space between the two buttons
//                         // Submit button with label
//                         Column(
//                           mainAxisSize: MainAxisSize
//                               .min, // Make the Column take only the space it needs
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   10), // Padding inside the box
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(
//                                     0.5), // Semi-transparent black background
//                                 borderRadius: BorderRadius.circular(
//                                     10), // Rounded corners
//                               ),
//                               child: IconButton(
//                                 icon: const Icon(Icons.check,
//                                     size: 40, color: Colors.white),
//                                 onPressed: () async {
//                                   if (_capturedImage != null) {
//                                     await uploadImageToFirebase(
//                                         _capturedImage!);
//                                     setState(() {
//                                       _capturedImage = null;
//                                     });
//                                   }
//                                 },
//                               ),
//                             ),
//                             const SizedBox(
//                                 height: 8), // Space between the icon and text
//                             const Text(
//                               "Submit",
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: _capturedImage == null
//           ? Padding(
//               padding: const EdgeInsets.all(16.0), // Adjust the padding here
//               child: FloatingActionButton(
//                 onPressed: () async {
//                   try {
//                     await _initializeControllerFuture;
//                     final image = await _controller.takePicture();
//                     setState(() {
//                       _capturedImage = File(image.path);
//                     });
//                   } catch (e) {
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Error taking picture')),
//                       );
//                     }
//                   }
//                 },
//                 child: const Icon(Icons.camera),
//               ),
//             )
//           : null,
//     );
//   }
// }

import 'package:complaint_vision/providers/complaint_provider.dart';
import 'package:complaint_vision/services/user_info.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // To handle the image file
import 'package:firebase_storage/firebase_storage.dart'; // Firebase storage package
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart'; // Alias the 'path' package
import 'package:complaint_vision/services/api_service.dart';

class GpsCameraPage extends StatefulWidget {
  final CameraDescription camera;

  const GpsCameraPage({super.key, required this.camera});

  @override
  State<GpsCameraPage> createState() => _GpsCameraPageState();
}

class _GpsCameraPageState extends State<GpsCameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  String locationDetails = "Location loading...";
  File? _capturedImage;
  String? city;
  String? town;
  String? state;
  String? country;
  String? village;
  String? globalClassificationResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkPermissions();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    final locationStatus = await Permission.location.request();
    if (locationStatus.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required')),
        );
      }
      return;
    }

    _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_isLocationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return;
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        fetchLocation(position.latitude, position.longitude);
      });
    });
  }

  Future<void> fetchLocation(double latitude, double longitude) async {
    final String url =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'YourAppName',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('address')) {
          final address = data['address'];
          city = address['city'] ?? 'N/A';
          town = address['town'] ?? 'N/A';
          village = address['village'] ?? 'N/A';
          state = address['state'] ?? 'N/A';
          country = address['country'] ?? 'N/A';

          setState(() {
            locationDetails =
                "City: $city\nTown: $town\nVillage: $village\nState: $state\nCountry: $country";
          });
        } else {
          setState(() {
            locationDetails = "No address found for the given coordinates.";
          });
        }
      } else {
        setState(() {
          locationDetails =
              "Failed to fetch location details. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        locationDetails = "Error fetching location: $e";
      });
    }
  }

  // Future<String?> uploadImageToFirebase(File image) async {
  //   try {
  //     final fileName = path.basename(image.path);
  //     final storageRef =
  //         FirebaseStorage.instance.ref().child('images/$fileName');
  //     final uploadTask = storageRef.putFile(image);
  //     final snapshot = await uploadTask.whenComplete(() {});
  //     final downloadUrl = await snapshot.ref.getDownloadURL();
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Complaint submitted successfully.')),
  //       );
  //     }
  //     return downloadUrl;
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error Submitting the complaint: $e')),
  //       );
  //     }
  //   }
  //   return null;
  // }
  // Global variable to store classification result

  Future<String?> uploadImageToFirebase(File image) async {
    try {
      final fileName = path.basename(image.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');

      // Upload Image to Firebase
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully.')),
        );
      }
      // Convert image to bytes for classification
      final imageBytes = await image.readAsBytes();
      final ApiService apiService = ApiService('http://192.168.159.44:5000/');

      // Classify Image
      final classificationResponse = await apiService.classifyImage(imageBytes);
      globalClassificationResult =
          classificationResponse['class_name']; // Store globally

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Submitting the complaint: $e')),
        );
      }
    }
    return null;
  }

  Future<void> SubmitComplaint(String imageUrl) async {
    final userId = UserInfoService.getUserId();
    // Check if userId is null before proceeding
    if (userId == null) {
      // Handle the case where userId is null (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is null. Please login again.')),
      );
      return; // Exit the method
    }

    final complaint = {
      'imageUrl': imageUrl,
      'city': city,
      'town': town,
      'village': village,
      'state': state,
      'country': country,
      'description': globalClassificationResult,
      'submissionTime': DateTime.now(),
      'progress': 'submitted',
    };

    try {
      // Assuming the fileComplaint method works asynchronously
      await Provider.of<ComplaintProvider>(context, listen: false)
          .fileComplaint(userId, complaint);
    } catch (e) {
      print("Error while filing complaint: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set a black background to avoid any white gaps.
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:  const Color.fromARGB(255, 242, 255, 238),
        title: const Text('Capture your complaints'),
      ),
      body: _capturedImage == null
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      // Use Positioned.fill to ensure the preview covers the full screen.
                      Positioned.fill(
                        child: CameraPreview(_controller),
                      ),
                      // Optional: display location info at the top-left corner.
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latitude: ${_currentPosition?.latitude ?? "Waiting..."}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Longitude: ${_currentPosition?.longitude ?? "Waiting..."}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                locationDetails,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : Stack(
              children: [
                // Display the captured image so it fills the screen.
                Positioned.fill(
                  child: Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
                // Bottom action buttons
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Make the Row take only the space it needs
                      children: [
                        // Retake button with label
                        Column(
                          mainAxisSize: MainAxisSize
                              .min, // Make the Column take only the space it needs
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  10), // Padding inside the box
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                    0.5), // Semi-transparent black background
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.refresh,
                                    size: 40, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _capturedImage = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Space between the icon and text
                            const Text(
                              "Retake",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(
                            width: 40), // Space between the two buttons
                        // Submit button with label
                        Column(
                          mainAxisSize: MainAxisSize
                              .min, // Make the Column take only the space it needs
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  10), // Padding inside the box
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                    0.5), // Semi-transparent black background
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.check,
                                    size: 40, color: Colors.white),
                                onPressed: () async {
                                  if (_capturedImage != null) {
                                    // Get the download URL after uploading the image
                                    final imageUrl =
                                        await uploadImageToFirebase(
                                            _capturedImage!);
                                    setState(() {
                                      _capturedImage = null;
                                    });
                                    // Ensure the image URL is not null before submitting
                                    if (imageUrl != null) {
                                      await SubmitComplaint(imageUrl);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Failed to upload image. Try again!')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Space between the icon and text
                            const Text(
                              "Submit",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _capturedImage == null
          ? Padding(
              padding: const EdgeInsets.all(16.0), // Adjust the padding here
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    final image = await _controller.takePicture();
                    setState(() {
                      _capturedImage = File(image.path);
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error taking picture')),
                      );
                    }
                  }
                },
                child: const Icon(Icons.camera),
              ),
            )
          : null,
    );
  }
}
