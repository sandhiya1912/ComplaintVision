import 'package:complaint_vision/services/user_info.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:complaint_vision/providers/complaint_provider.dart';
import 'track_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;


class GrievancePage extends StatefulWidget {
  final File? cameraFile;
  final String? locationDetails;

  GrievancePage({this.cameraFile, this.locationDetails});

  @override
  _GrievancePageState createState() => _GrievancePageState();
}

class _GrievancePageState extends State<GrievancePage> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? phoneNo, location;
  String? grievanceType;
  String? grievanceSubType;
  String? description;
  DateTime? incidentDateTime;
  List<File> uploadedFiles = [];
  List<File> cameraFiles = [];

  List<String> grievanceTypes = [
    'Electricity',
    'Water',
    'Road',
    'Sanitation',
    'Public Transport',
  ];

  Map<String, List<String>> grievanceSubtypes = {
    'Electricity': ['Power Outage', 'Meter Issue', 'Wiring Problem'],
    'Water': ['Low Pressure', 'Water Leakage', 'Contaminated Water'],
    'Road': ['Potholes', 'Road Blockage', 'Accident'],
    'Sanitation': ['Garbage Collection', 'Sewage Overflow', 'Cleanliness'],
    'Public Transport': ['Bus Delay', 'Overcrowding', 'Ticket Issue'],
  };

  String? selectedState = 'Tamil Nadu';
  List<String> tamilNaduDistricts = [
    'Chennai',
    'Coimbatore',
    'Madurai',
    'Trichy'
  ];

  List<String> uploadedFileNames = [];
  List<String> selectedSubtypes = [];

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          uploadedFiles.clear();
          for (var file in result.files) {
            if (file.bytes != null) {
              uploadedFiles.add(File(file.name)); // Just a placeholder
              uploadedFileNames.add(file.name);
            }
          }
        } else {
          uploadedFiles = result.paths.map((path) => File(path!)).toList();
          uploadedFileNames = result.names
              .where((name) => name != null)
              .cast<String>()
              .toList();
        }
      });
    }
  }

  Future<void> _capturePhotoOrVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        cameraFiles.add(File(pickedFile.path));
      });
    }
  }

// Future<String> uploadFile(File file) async {
//     try {
//       String fileName = path.basename(file.path); // Use the alias 'path.'
//       Reference storageRef =
//           FirebaseStorage.instance.ref().child('complaints/$fileName');
//       UploadTask uploadTask = storageRef.putFile(file);
//       TaskSnapshot snapshot = await uploadTask;
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print("Error uploading file: $e");
//       return '';
//     }
//   }
  Future<String> uploadFile(File file) async {
    try {
      String fileName =
          path.basename(file.path); // Get the file name from path.
      Reference storageRef =
          FirebaseStorage.instance.ref().child('complaints/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);

      // Adding a listener to check the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        switch (snapshot.state) {
          case TaskState.running:
            print("Upload in progress...");
            break;
          case TaskState.success:
            print("Upload complete.");
            break;
          case TaskState.canceled:
            print("Upload was canceled.");
            break;
          default:
            break;
        }
      });

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Download URL: $downloadUrl"); // Log the download URL
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return ''; // Return an empty string if there is an error
    }
  }

// Future<String> uploadFile(File file) async {
//   try {
//     // Retrieve the App Check token (handle nullability)
//     String appCheckToken = await FirebaseAppCheck.instance.getToken() ?? '';

//     // Get the file name from the file path
//     String fileName = path.basename(file.path);

//     // Create a reference to the Firebase Storage location
//     Reference storageRef = FirebaseStorage.instance.ref().child('complaints/$fileName');

//     // Upload the file to Firebase Storage with App Check token as metadata
//     UploadTask uploadTask = storageRef.putFile(
//       file,
//       SettableMetadata(customMetadata: {'appCheckToken': appCheckToken}),
//     );

//     // Wait for the upload to complete
//     TaskSnapshot snapshot = await uploadTask;

//     // Retrieve the download URL after the file is uploaded
//     String downloadUrl = await snapshot.ref.getDownloadURL();

//     return downloadUrl;
//   } catch (e) {
//     print("Error uploading file: $e");
//     return '';
//   }
// }

  Future<List<String>> uploadFiles(List<File> files) async {
    List<String> fileUrls = [];
    for (File file in files) {
      String url = await uploadFile(file);
      if (url.isNotEmpty) {
        fileUrls.add(url);
      }
    }
    return fileUrls;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = UserInfoService.getUserId();

      // Check if userId is null before proceeding
      if (userId == null) {
        // Handle the case where userId is null (e.g., show an error message)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID is null. Please login again.')),
        );
        return; // Exit the method
      }

      List<String> uploadedFileUrls = await uploadFiles(uploadedFiles);
      List<String> cameraFileUrls = await uploadFiles(cameraFiles);

      // Log the uploaded URLs for debugging purposes
      print("Uploaded File URLs: $uploadedFileUrls"); // Log uploaded file URLs
      print("Camera File URLs: $cameraFileUrls"); // Log camera file URLs

      final complaint = {
        'userId': userId,
        'name': name,
        'phoneNo': phoneNo,
        'city': location,
        'grievanceType': grievanceType,
        'grievanceSubType': grievanceSubType,
        'description': description,
        'incidentDateTime': incidentDateTime,
        'uploadedFiles': uploadedFileUrls,
        'cameraFiles': cameraFileUrls,
        'submissionTime': DateTime.now(),
        'progress': 'submitted',
      };

      try {
        // Assuming the fileComplaint method works asynchronously
        await Provider.of<ComplaintProvider>(context, listen: false)
            .fileComplaint(userId, complaint);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint filed successfully!')),
        );

        // Navigate to the Track Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TrackPage(),
          ),
        );
      } catch (e) {
        // Handle error if complaint submission fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to file complaint: $e')),
        );
        print("Error while filing complaint: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File a Complaint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Form fields go here (same as before)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (value) {
                  name = value;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (value) {
                  phoneNo = value;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Type of Grievance',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                value: grievanceType,
                items: grievanceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    grievanceType = value;
                    selectedSubtypes = grievanceSubtypes[value] ?? [];
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a grievance type';
                  return null;
                },
              ),
              SizedBox(height: 10),
              if (selectedSubtypes.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Subtype',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: selectedSubtypes.map((subtype) {
                    return DropdownMenuItem(
                      value: subtype,
                      child: Text(subtype),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      grievanceSubType = value;
                    });
                  },
                ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Incident Date and Time',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: incidentDateTime != null
                      ? "${incidentDateTime!.day}/${incidentDateTime!.month}/${incidentDateTime!.year}"
                      : '',
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      incidentDateTime = pickedDate;
                    });
                  }
                },
                validator: (value) {
                  if (incidentDateTime == null) {
                    return 'Please pick a date and time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location - District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (value) {
                  location = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location'; // Error message if location is empty
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Incident Description',
                  hintText: 'Enter your complaints',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                maxLines: 5,
                onSaved: (value) {
                  description = value;
                },
              ),
              Column(
                children: [
                  // Upload Button
                  TextButton.icon(
                    onPressed: _pickFiles,
                    icon: Icon(Icons.file_upload),
                    label: Text('Upload Image/Video/File'),
                  ),
                  if (uploadedFileNames.isNotEmpty)
                    Text('Selected: ${uploadedFileNames.length} files'),

                  SizedBox(height: 10),

                  // Capture Button
                  TextButton.icon(
                    onPressed: _capturePhotoOrVideo,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Capture Photo/Video'),
                  ),

                  if (cameraFiles.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Captured Images:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: cameraFiles.map((file) {
                            return Image.file(
                              file,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height:10),
              if (widget.cameraFile != null) Image.file(widget.cameraFile!),
              SizedBox(height: 10),
              if (widget.locationDetails != null)
                TextFormField(
                  initialValue: widget.locationDetails,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Location Details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('File Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:complaint_vision/providers/complaint_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:provider/provider.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;
// import '../services/api_service.dart';
// import '../services/user_info.dart';

// class GrievancePage extends StatefulWidget {
//   const GrievancePage({Key? key}) : super(key: key);

//   @override
//   _GrievancePageState createState() => _GrievancePageState();
// }

// class _GrievancePageState extends State<GrievancePage> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService _apiService = ApiService('http://192.168.50.92:5000');
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
//       final source = await showDialog<ImageSource>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Choose Image Source"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, ImageSource.camera),
//               child: const Text("Camera"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, ImageSource.gallery),
//               child: const Text("Gallery"),
//             ),
//           ],
//         ),
//       );

//       if (source == null) return;

//       final XFile? pickedFile = await picker.pickImage(
//         source: source,
//         maxWidth: 1800,
//         maxHeight: 1800,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         final file = File(pickedFile.path);

//         setState(() {
//           if (source == ImageSource.camera) {
//             _cameraFiles.add(file);
//           } else {
//             _uploadedFiles.add(file);
//           }
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
//                     TextFormField(
//                       controller: _descriptionController,
//                       decoration: const InputDecoration(
//                         labelText: 'Description',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLines: 4,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a description of the issue';
//                         }
//                         return null;
//                       },
//                     ),
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