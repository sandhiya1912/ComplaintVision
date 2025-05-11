// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:complaint_vision/providers/complaint_provider.dart';

// class RecentComplaintTracking extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final complaintProvider = Provider.of<ComplaintProvider>(context);
//     final latestComplaint = complaintProvider.complaints.isNotEmpty
//         ? complaintProvider.complaints.last
//         : null;

//     // Use MediaQuery to get the screen width for responsive design
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double circleSize =
//         screenWidth * 0.1; // Set circle size relative to screen width
//     final double lineWidth =
//         screenWidth * 0.2; // Set line width relative to screen width

//     return Container(
//       margin: EdgeInsets.all(6), // Adds margin around the floating box
//       padding: EdgeInsets.all(6), // Padding inside the box
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15), // Rounded corners for the box
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 5,
//             blurRadius: 10,
//             offset: Offset(0, 5), // Shadow position
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Recent Complaint Tracking',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Handle 'change' action here
//                 },
//                 child: Text(
//                   'Change',
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           if (latestComplaint != null) ...[
//             Text(
//               '${latestComplaint['grievanceType']} - ${latestComplaint['description']}',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 progressCircle(
//                   status: ComplaintStatus.submitted,
//                   isActive: true, // Always active for "submitted"
//                   circleSize: circleSize,
//                 ),
//                 progressLine(lineWidth: lineWidth),
//                 progressCircle(
//                   status: ComplaintStatus.inProgress,
//                   isActive: latestComplaint['progress'] == 'InProgress' || latestComplaint['progress'] == 'Solved',
//                   circleSize: circleSize,
//                 ),
//                 progressLine(lineWidth: lineWidth),
//                 progressCircle(
//                   status: ComplaintStatus.solved,
//                   isActive: latestComplaint['progress'] == 'Solved' || 
//                             (latestComplaint['progress'] != 'InProgress'),
//                   circleSize: circleSize,
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             // The row containing the status texts has been removed as requested.
//           ] else ...[
//             Text('No recent complaints available.'),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget progressCircle({
//     required ComplaintStatus status,
//     required bool isActive,
//     required double circleSize,
//   }) {
//     return Column(
//       children: [
//         Container(
//           width: circleSize,
//           height: circleSize,
//           decoration: BoxDecoration(
//             color: isActive ? Colors.green : Colors.grey,
//             shape: BoxShape.circle,
//           ),
//         ),
//         SizedBox(height: 10),
//         Text(
//           status
//               .toString()
//               .split('.')
//               .last, // Get enum name (you can also remove this if needed)
//           style: TextStyle(
//             fontSize: 14,
//             color: isActive ? Colors.green : Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget progressLine({required double lineWidth}) {
//     return Container(
//       width: lineWidth,
//       height: 6,
//       color: Colors.grey, // You can adjust the color here
//     );
//   }
// }

// // Enum for ComplaintStatus
// enum ComplaintStatus { submitted, inProgress, solved }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:complaint_vision/providers/complaint_provider.dart';

class RecentComplaintTracking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final latestComplaint = complaintProvider.complaints.isNotEmpty
        ? complaintProvider.complaints.last
        : null;

    // Determine progress value and message based on complaint status
    double progressValue = 0.0;
    String progressMessage = "No recent complaints available.";

    if (latestComplaint != null) {
      switch (latestComplaint['progress']) {
        case 'submitted':
          progressValue = 0.33;
          progressMessage = "Your complaint is submitted.";
          break;
        case 'InProgress':
          progressValue = 0.66;
          progressMessage = "Your complaint is under progress.";
          break;
        case 'Solved':
          progressValue = 1.0;
          progressMessage = "Complaint solved successfully!";
          break;
      }
    }

    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16), // Padding inside the box
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Complaint Tracking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Handle 'change' action here
                },
                child: Text(
                  'Change',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (latestComplaint != null) ...[
            Text(
              'Issue - ${latestComplaint['description']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 10, // Increased height for better visibility
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  progressMessage, // Display the dynamic status message
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ] else ...[
            Text(progressMessage), // Show message if no complaints are available
          ],
        ],
      ),
    );
  }
}
