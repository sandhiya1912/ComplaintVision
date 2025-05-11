// import 'package:complaint_vision/providers/complaint_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;
// import '../services/api_service.dart';
// import '../services/user_info.dart';

// class GrievanceImagePage extends StatefulWidget {
//   const GrievanceImagePage({Key? key}) : super(key: key);

//   @override
//   _GrievanceImagePageState createState() => _GrievanceImagePageState();
// }

// class _GrievanceImagePageState extends State<GrievanceImagePage> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService _apiService = ApiService('http://192.168.45.44:5000/');
//   bool _isLoading = false;
//   String? _classificationResult;

//   // Form Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   DateTime? _incidentDateTime;
//   List<File> _uploadedFiles = [];
//   List<File> _cameraFiles = [];
//   String _selectedState = 'Tamil Nadu';
//   String? _selectedDistrict;

//   Future<void> _pickAndClassifyImage() async {
//     setState(() => _isLoading = true);
//     try {
//       final picker = ImagePicker();
//       final XFile? pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1800,
//         maxHeight: 1800,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         final file = File(pickedFile.path);

//         // Add to uploaded files
//         setState(() {
//           _uploadedFiles.add(file);
//         });

//         // Classify image
//         final result = await _apiService.classifyImage(bytes);

//         setState(() {
//           _classificationResult = result['class_name'];
//         });
//       }
//     } catch (e) {
//       _showErrorDialog('Error processing image: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<String> _uploadFileToStorage(File file) async {
//     try {
//       String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
//       Reference ref = FirebaseStorage.instance.ref().child('complaints/$fileName');
//       UploadTask uploadTask = ref.putFile(file);
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       throw Exception('Failed to upload file: $e');
//     }
//   }

//   Future<void> _submitComplaint() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final userId = UserInfoService.getUserId();
//       if (userId == null) throw Exception('User not found');

//       // Upload all files and get URLs
//       List<String> fileUrls = [];
//       for (File file in [..._uploadedFiles, ..._cameraFiles]) {
//         String url = await _uploadFileToStorage(file);
//         fileUrls.add(url);
//       }

//       // Prepare complaint data
//       final complaintData = {
//         'userId': userId,
//         'name': _nameController.text,
//         'phoneNo': _phoneController.text,
//         'classificationResult': _classificationResult,
//         'description': _descriptionController.text,
//         'incidentDateTime': _incidentDateTime?.toIso8601String(),
//         'fileUrls': fileUrls,
//         'state': _selectedState,
//         'district': _selectedDistrict,
//         'status': 'submitted',
//       };

//       // Save to Firebase via provider
//       await Provider.of<ComplaintProvider>(context, listen: false)
//           .fileComplaint(userId, complaintData);

//       _showSuccessMessage();
//       Navigator.pushReplacementNamed(context, '/track');
//     } catch (e) {
//       _showErrorDialog('Failed to submit complaint: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showSuccessMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Complaint filed successfully!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('File a Complaint'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _pickAndClassifyImage,
//                       icon: const Icon(Icons.image),
//                       label: const Text('Upload & Classify Image'),
//                     ),
//                     if (_classificationResult != null)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Detected Issue: $_classificationResult',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     // Rest of your form widgets...
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Name (Optional)',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: const InputDecoration(
//                         labelText: 'Phone Number (Optional)',
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 16),
//                     // Rest of your form fields here...
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: _submitComplaint,
//                       child: const Text('Submit Complaint'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:complaint_vision/pages/track_page.dart';
import 'package:complaint_vision/providers/complaint_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:complaint_vision/services/api_service.dart';
import 'package:complaint_vision/services/user_info.dart';

class GrievanceImagePage extends StatefulWidget {
  const GrievanceImagePage({Key? key}) : super(key: key);

  @override
  _GrievanceImagePageState createState() => _GrievanceImagePageState();
}

class _GrievanceImagePageState extends State<GrievanceImagePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService('http://192.168.159.44:5000/');
  bool _isLoading = false;
  String? _classificationResult;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _incidentDateTime;
  List<File> _uploadedFiles = [];
  String _selectedState = 'Tamil Nadu';
  String? _selectedDistrict;

  Future<void> _pickAndClassifyImage() async {
    setState(() => _isLoading = true);
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Add to uploaded files
        setState(() {
          _uploadedFiles.add(file);
        });

        // Classify image
        final bytes = await pickedFile.readAsBytes();
        final result = await _apiService.classifyImage(bytes);
        setState(() {
          _classificationResult = result['class_name'];
        });
      }
    } catch (e) {
      _showErrorDialog('Error processing image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadFile(File file) async {
    try {
      String fileName = path.basename(file.path);
      Reference storageRef =
          FirebaseStorage.instance.ref().child('complaints/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return '';
    }
  }

  Future<List<String>> _uploadFiles(List<File> files) async {
    List<String> fileUrls = [];
    for (File file in files) {
      String url = await _uploadFile(file);
      if (url.isNotEmpty) {
        fileUrls.add(url);
      }
    }
    return fileUrls;
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = UserInfoService.getUserId();
      List<String> uploadedFileUrls = await _uploadFiles(_uploadedFiles);

      // Prepare complaint data
      final complaintData = {
        'userId': userId,
        'name': _nameController.text,
        'phoneNo': _phoneController.text,
        'classificationResult': _classificationResult,
        'description': _descriptionController.text,
        'incidentDateTime': _incidentDateTime?.toIso8601String(),
        'fileUrls': uploadedFileUrls,
        'state': _selectedState,
        'district': _selectedDistrict,
        'status': 'submitted',
      };

      // Use ComplaintProvider to file the complaint
      await Provider.of<ComplaintProvider>(context, listen: false)
          .fileComplaint(userId!, complaintData);

      _showSuccessMessage();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrackPage(),
        ),
      );
    } catch (e) {
      _showErrorDialog('Failed to submit complaint: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint filed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File a Complaint'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickAndClassifyImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Upload & Classify Image'),
                    ),
                    if (_classificationResult != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Detected Issue: $_classificationResult',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitComplaint,
                      child: const Text('Submit Complaint'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
