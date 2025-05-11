import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComplaintProvider with ChangeNotifier {
  List<Map<String, dynamic>> _complaints = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> get complaints => _complaints;

  // Fetch complaints for all users (Admin view)
  Future<void> fetchAllComplaints() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collectionGroup('complaints').get();
      _complaints = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Include the document ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      print("complaint fetched");
      notifyListeners(); // Notify listeners to update the UI
    } catch (error) {
      print("Error fetching all complaints: $error");
    }
  }

  // Fetch complaints for a specific user
  Future<void> fetchUserComplaints(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('complaints')
          .get();
      _complaints = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Include the document ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      notifyListeners(); // Notify listeners to rebuild UI
    } catch (e) {
      print("Error fetching user complaints: $e");
    }
  }

  // Add a new complaint for the user
  Future<void> fileComplaint(
      String userId, Map<String, dynamic> complaintData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('complaints')
          .add(complaintData);
      // Optionally refresh the user's complaints after adding a new one
      await fetchUserComplaints(userId);
    } catch (e) {
      print("Error filing complaint: $e");
    }
  }

// Update the progress of a complaint for a user and handle proof uploads
  Future<void> updateComplaintProgress(String userId, String complaintId,
      String progress, List<String> proofs) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('complaints')
          .doc(complaintId)
          .update({
        'progress': progress,
        'proofs': proofs, // Handle proof uploads and their paths
      });

      // Update the local complaint list
      int index =
          _complaints.indexWhere((complaint) => complaint['id'] == complaintId);
      if (index != -1) {
        _complaints[index]['progress'] = progress; // Update the progress
        _complaints[index]['proofs'] = proofs; // Update the proofs
        notifyListeners(); // Notify listeners to rebuild UI
      }

      // Optionally refetch the user's complaints to reflect changes
      // await fetchUserComplaints(userId); // Uncomment if you want to refetch complaints after update
    } catch (e) {
      print("Error updating complaint: $e");
    }
  }

  // Update complaint progress for all users (Admin functionality)
  Future<void> updateComplaintProgressForAll(
      String complaintId, String progress, List<String> proofs) async {
    try {
      // Find the complaint document by its ID across all users (admin use)
      QuerySnapshot snapshot = await _firestore
          .collectionGroup('complaints')
          .where('id', isEqualTo: complaintId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        var docRef = snapshot.docs.first.reference;

        // Update the document in Firestore
        await docRef.update({
          'progress': progress,
          'proofs': proofs, // Handle proof uploads and their paths
        });

        // Update the local complaint list
        int index = _complaints
            .indexWhere((complaint) => complaint['id'] == complaintId);
        if (index != -1) {
          _complaints[index]['progress'] = progress;
          _complaints[index]['proofs'] = proofs;
          notifyListeners();
        }
      }
    } catch (error) {
      print("Error updating complaint progress for all users: $error");
    }
  }
}
