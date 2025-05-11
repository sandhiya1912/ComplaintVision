import 'package:complaint_vision/admin/admin_home_page.dart';
import 'package:complaint_vision/pages/news_details.dart';
import 'package:complaint_vision/providers/complaint_provider.dart';
import 'package:complaint_vision/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grievance_page.dart';
import 'track_page.dart';
import 'grievance_image_page.dart';
import 'recent_complaint_tracking.dart'; // Import the new widget
import 'package:firebase_auth/firebase_auth.dart'; // Firebase for sign-out
import 'auth_page.dart'; // Your authentication page
import 'package:camera/camera.dart'; // Import the camera package

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Store the available cameras here
  List<CameraDescription>? cameras;

  List<String> eventImages = [
    'lib/assets/images/vijay_paranthur.jpeg', // Event 1 image
    'lib/assets/images/min-thadai.webp', // Event 2 image
    'lib/assets/images/aritapatti_tun.avif', // Event 3 image
  ];

  List<String> eventTitles = [
    ' Paranthur Airport Issue',
    ' Chennai - Power shutdown ',
    ' Tungsten Mining Controversy ',
  ];

  List<String> eventDescriptions = [
    'Actor-politician Vijay, leader of Tamizhaga Vetri Kazhagam (TVK), strongly opposed the proposed Parandur airport in Tamil Nadu, pledging support to protesting farmers. Speaking at Podavur, he accused the ruling DMK of prioritizing benefits over environmental concerns, questioning their silence after previously opposing similar projects. Vijay emphasized the project threat to farmland and water bodies, citing climate change and Chennai’s recurring floods. Launching his ‘Kala Arasiyal’ initiative, he vowed to stand with farmers, urging them to stay hopeful. His visit marked the 910th day of protests, countering criticism of his political inactivity since TVK’s launch in February 2024.',
    'The Tamil Nadu government has announced a scheduled power shutdown in various parts of Chennai for maintenance work. Areas including Perumbakkam, Mudichur, Thiruvanchery, and Chengalpattu will be affected. In Perumbakkam, localities such as Gandhi Street, Ramaya Nagar, and Perumbakkam Main Road will experience outages. Mudichur will see power cuts in Balaji Nagar, Swamy Nagar, and Kommayamman Nagar, while Thiruvanchery and Chengalpattu, including Kumaran Nagar and JJ Nagar, will also be impacted. Residents in these areas are advised to plan accordingly as the maintenance work is expected to take place throughout the scheduled duration.',
    'The Tamil Nadu government has announced a scheduled power shutdown in various parts of Chennai for maintenance work. Areas including Perumbakkam, Mudichur, Thiruvanchery, and Chengalpattu will be affected. In Perumbakkam, localities such as Gandhi Street, Ramaya Nagar, and Perumbakkam Main Road will experience outages. Mudichur will see power cuts in Balaji Nagar, Swamy Nagar, and Kommayamman Nagar, while Thiruvanchery and Chengalpattu, including Kumaran Nagar and JJ Nagar, will also be impacted. Residents in these areas are advised to plan accordingly as the maintenance work is expected to take place throughout the scheduled duration.',
  ];

  // Initialize the camera on app startup
  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      setState(() {
        cameras = availableCameras;
      });
    });
  }

  // Fetch complaints based on the user ID
  Future<void> _fetchComplaints() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<ComplaintProvider>(context, listen: false)
          .fetchUserComplaints(user.uid);
    }
    print(user);
  }

  // Sign out function
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  // Navigate to Admin Page
  void _navigateToAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminHomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaint Vision',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 242, 255, 238),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Profile action
            },
          ),
          IconButton(
            icon: Icon(Icons.question_answer),
            onPressed: () {
              // V_bot action
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                _logout(context); // Call the logout function
              } else if (value == 'admin') {
                _navigateToAdmin(context); // Navigate to Admin Page
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'signout',
                  child: Text('Sign Out'),
                ),
                const PopupMenuItem<String>(
                  value: 'admin',
                  child: Text('Admin Page'), // New Admin Page option
                ),
              ];
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 242, 255, 238),
        child: FutureBuilder(
          future: _fetchComplaints(), // Fetch complaints on page load
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while fetching data
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // After the data is fetched, display the main content
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search complaints...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Buttons for File, Track, Solved
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GrievancePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 195, 237, 183),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          minimumSize: Size(70, 40), // Keeps button size fixed
                        ),
                        child: Text(
                          'File',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // Increased font size
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 195, 237, 183),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          minimumSize: Size(70, 40), // Keeps button size fixed
                        ),
                        child: Text(
                          'Track',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // Increased font size
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => GrievanceImagePage(),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 195, 237, 183),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          minimumSize: Size(70, 40), // Keeps button size fixed
                        ),
                        child: Text(
                          'Solved',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // Increased font size
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Recent Complaint Tracking Component
                  RecentComplaintTracking(),
                  SizedBox(height: 20),
                  // News and Activities Section
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Left padding added
                    child: Text(
                      'News & Activities',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),

// Scrollable Events
                  Container(
                    height: 170, // Fixed height for event cards
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      itemCount: eventImages.length, // Number of events
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to NewsDetailPage and pass the event data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailPage(
                                  title: eventTitles[index],
                                  image: eventImages[
                                      index], // Can still pass asset paths here
                                  description: eventDescriptions[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 120, // Width for each event card
                            margin: EdgeInsets.symmetric(
                                horizontal: 10), // Space between cards
                            decoration: BoxDecoration(
                              color: Colors.green[100], // Background color
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  eventImages[
                                      index], // Use Image.asset for assets
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  eventTitles[index], // Event title
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        camera: cameras?.isNotEmpty == true
            ? cameras![0]
            : null, // Pass camera if available
      ),
    );
  }
}
