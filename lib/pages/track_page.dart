// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For formatting time
// import 'package:provider/provider.dart';
// import 'package:complaint_vision/providers/complaint_provider.dart';

// class TrackPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Access the complaints from ComplaintProvider
//     final complaints = Provider.of<ComplaintProvider>(context).complaints;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Track Complaints'),
//       ),
//       body: complaints.isEmpty
//           ? Center(child: Text('No complaints filed yet.'))
//           : ListView.builder(
//               itemCount: complaints.length,
//               itemBuilder: (context, index) {
//                 final complaint = complaints[index];

//                 // Format submission time to 12-hour format with AM/PM
//                 String formattedTime = DateFormat('MM/dd/yyyy hh:mm a')
//                     .format(complaint['submissionTime'].toDate()); // Firestore stores Timestamps, use .toDate()

//                 return Card(
//                   child: ListTile(
//                     title: Text(
//                       complaint['description'] ?? 'No Description',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold, // Make description bold
//                         fontSize: 20, // You can adjust the font size as needed
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (complaint['grievanceType'] != null)
//                           Text('Grievance Type: ${complaint['grievanceType']}'),
//                         if (complaint['grievanceSubType'] != null)
//                           Text('Sub Type: ${complaint['grievanceSubType']}'),
//                         Text('Submitted at: $formattedTime'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For formatting time
// import 'package:provider/provider.dart';
// import 'package:complaint_vision/providers/complaint_provider.dart';

// class TrackPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Access the complaints from ComplaintProvider
//     final complaints = Provider.of<ComplaintProvider>(context).complaints;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Track Complaints'),
//       ),
//       body: complaints.isEmpty
//           ? Center(child: Text('No complaints filed yet.'))
//           : ListView.builder(
//               itemCount: complaints.length,
//               itemBuilder: (context, index) {
//                 final complaint = complaints[index];

//                 // Format submission time to 12-hour format with AM/PM
//                 String formattedTime = DateFormat('MM/dd/yyyy hh:mm a')
//                     .format(complaint['submissionTime'].toDate()); // Firestore stores Timestamps, use .toDate()

//                 return Card(
//                   child: ListTile(
//                     title: Text(
//                       complaint['description'] ?? 'No Description',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold, // Make description bold
//                         fontSize: 20, // You can adjust the font size as needed
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (complaint['grievanceType'] != null)
//                           Text('Grievance Type: ${complaint['grievanceType']}'),
//                         if (complaint['grievanceSubType'] != null)
//                           Text('Sub Type: ${complaint['grievanceSubType']}'),
//                         Text('Submitted at: $formattedTime'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting time
import 'package:provider/provider.dart';
import 'package:complaint_vision/providers/complaint_provider.dart';

class TrackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the complaints from ComplaintProvider
    final complaints = Provider.of<ComplaintProvider>(context).complaints;

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Complaints'),
        backgroundColor: const Color.fromARGB(255, 242, 255, 238),
      ),
      body: Container(
        
        child: complaints.isEmpty
            ? Center(child: Text('No complaints filed yet.'))
            : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
        
                  // Format submission time to 12-hour format with AM/PM
                  String formattedTime = complaint['submissionTime'] != null
                      ? DateFormat('MM/dd/yyyy hh:mm a')
                          .format(complaint['submissionTime'].toDate())
                      : 'Unknown time'; // Provide a default value when submissionTime is null
        // Firestore stores Timestamps, use .toDate()
        
                  return Card(
                    color:const Color.fromARGB(255, 250, 250, 250),
                    child: ListTile(
                      // Grievance description and city in the title
                      title: Text(
                        '${complaint['description'] ?? 'No description'} at ${complaint['city'] ?? 'Unknown city'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
        
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Showing the incident submission time
                          Text('Submitted at: $formattedTime'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
