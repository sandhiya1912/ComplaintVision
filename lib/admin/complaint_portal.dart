import 'package:complaint_vision/providers/complaint_provider.dart';
import 'package:complaint_vision/widgets/firebase_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComplaintPortal extends StatefulWidget {
  @override
  _ComplaintPortalState createState() => _ComplaintPortalState();
}

class _ComplaintPortalState extends State<ComplaintPortal> {
  @override
  void initState() {
    super.initState();
    // Fetch complaints when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false)
          .fetchAllComplaints();
    });
  }

  void _showComplaintDetails(
      BuildContext context, Map<String, dynamic> complaint) {
    String? _selectedProgress = complaint['status'] ?? 'Accepted';

    // Fetch the list of uploaded files (image URLs)
    List<String> _uploadedFiles =
        (complaint['uploadedFiles'] as List<dynamic>?)?.cast<String>() ?? [];

    print('Selected progress value: $_selectedProgress'); // Debugging step

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Complaint Details'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${complaint['id']}'),
                    Text('Name: ${complaint['name'] ?? 'No Title'}'),
                    Text(
                        'Description: ${complaint['description'] ?? 'No Description'}'),

                    // Check if there are uploaded files (images)
                    if (_uploadedFiles.isNotEmpty)
                      Column(
                        children: _uploadedFiles.map((fileUrl) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child:
                                FirebaseImageViewer(imageUrl: fileUrl.trim()),
                          );
                        }).toList(),
                      )
                    else
                      Text('No images available'),

                    SizedBox(height: 20),
                    Text('Progress:'),
                    DropdownButton<String>(
                      hint: Text('Select Progress'),
                      value: _selectedProgress,
                      items: ['Accepted', 'InProgress', 'Solved']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProgress = newValue ?? 'Accepted';
                          print('New progress selected: $_selectedProgress');
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Upload Proof:'),
                    ElevatedButton(
                      onPressed: () {
                        // Implement file upload functionality
                      },
                      child: Text('Upload File'),
                    ),
                    SizedBox(height: 10),
                    for (var file in _uploadedFiles) Text(file),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_selectedProgress != null) {
                      Provider.of<ComplaintProvider>(context, listen: false)
                          .updateComplaintProgress(
                              complaint['userId'],
                              complaint['id'],
                              _selectedProgress!,
                              _uploadedFiles);
                      Provider.of<ComplaintProvider>(context, listen: false)
                          .fetchAllComplaints(); // Refetch complaints to update

                      // Show confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Complaint updated successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
                TextButton(
                  onPressed: () {
                    // Show cancellation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Update cancelled.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Portal'),
      ),
      body: ListView.builder(
        itemCount: complaintProvider.complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaintProvider.complaints[index];
          return ListTile(
            title:
                Text(complaint['name'] ?? 'No Title'), // Provide default value
            subtitle: Text(complaint['description'] ??
                'No Description'), // Provide default value
            trailing: ElevatedButton(
              onPressed: () => _showComplaintDetails(context, complaint),
              child: Text('View'),
            ),
          );
        },
      ),
    );
  }
}
