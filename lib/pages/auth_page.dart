import 'package:complaint_vision/admin/admin_home_page.dart';
import 'package:complaint_vision/providers/complaint_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart'; 
import 'package:complaint_vision/widgets/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:complaint_vision/services/user_info.dart';
import 'package:complaint_vision/utils/hash_utils.dart';


class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignUp = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  void _toggleForm() {
    setState(() {
      _isSignUp = !_isSignUp; 
      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  String? _validateEmail(String? value) {
    final emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; 
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

 void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      UserCredential userCredential;
      if (_isSignUp) {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('User signed up: ${userCredential.user!.email}');
      } else {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('User logged in: ${userCredential.user!.email}');
      }
      //anonymisation
      final uid = userCredential.user!.uid;

      final userHash = HashUtils.getUserHash(uid);
      print("User Anonymous Hash: $userHash");
      UserInfoService.setUserInfo(
        uid: uid,
        userEmail: userCredential.user!.email!,
      );

      await Provider.of<ComplaintProvider>(context, listen: false)
          .fetchUserComplaints(uid); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error: $e');
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Complaint Vision',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.green, 
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.admin_panel_settings), 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AdminHomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey, // Wrap the form with a Form widget
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text for login/signup indication
                      Text(
                        _isSignUp ? 'Create Account' : 'Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _isSignUp
                            ? 'Already have an account? Login'
                            : 'Don\'t have an account? Sign Up',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Name Input (only for Sign Up)
                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),

                        // Phone Number Input
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                      ],

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: _validateEmail, 
                      ),
                      SizedBox(height: 15),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      SizedBox(height: 10),

                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator:
                              _validateConfirmPassword, 
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Confirm you are not a robot',
                          style: TextStyle(fontSize: 12),
                        ),
                        CheckboxListTile(
                          value: true,
                          onChanged: (value) {
                            // Handle CAPTCHA confirmation
                          },
                          title: Text('I am not a robot'),
                        ),
                        SizedBox(height: 10),
                      ],

                      if (!_isSignUp) ...[
                        TextButton(
                          onPressed: () {
                            // Implement forgot password logic
                          },
                          child: Text(
                            'Forgot your password?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                      SizedBox(
                        width: 200, 
                        height: 50, 
                        child: ElevatedButton(
                          onPressed: _submitForm, 
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    16), // Optional: Adjust padding inside the button
                            backgroundColor: const Color.fromARGB(
                                255, 199, 235, 195), // Set button color
                          ),
                          child: Text(
                            _isSignUp ? 'Sign Up' : 'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors
                                  .black, 
                            ),
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: _toggleForm,
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Login'
                              : 'Don\'t have an account? Sign Up',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20), 

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // google button
                  SquareTile(imagePath: 'lib/assets/images/google_icon.png'),

                  SizedBox(width: 25),

                  // apple button
                  SquareTile(imagePath: 'lib/assets/images/facebook_icon.png')
                ],
              ),

              const SizedBox(height: 50),

              // not a member? register now
            ],
          ),
        ),
      ),
    );
  }
}
