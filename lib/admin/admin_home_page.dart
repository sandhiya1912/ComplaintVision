import 'package:flutter/material.dart';
import 'complaint_portal.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Vision'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Implement actions here
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.lightGreen,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('(Icon) Admin'),
                ),
                Divider(),
                ListTile(
                  title: Text('Complaint Portal'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ComplaintPortal()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Scheduled Complaints'),
                  onTap: () {
                    // Implement navigation
                  },
                ),
                ListTile(
                  title: Text('Resolved'),
                  onTap: () {
                    // Implement navigation
                  },
                ),
                ListTile(
                  title: Text('Feedbacks'),
                  onTap: () {
                    // Implement navigation
                  },
                ),
                ListTile(
                  title: Text('Officers'),
                  onTap: () {
                    // Implement navigation
                  },
                ),
                ListTile(
                  title: Text('Settings'),
                  onTap: () {
                    // Implement navigation
                  },
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Center(
              child: Text(
                'Welcome to Admin Dashboard',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
