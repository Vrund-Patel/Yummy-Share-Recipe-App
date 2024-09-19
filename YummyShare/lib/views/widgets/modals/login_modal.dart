import 'package:flutter/material.dart';
import 'package:yummyshare/models/helper/auth.dart';
import 'package:yummyshare/views/screens/page_switcher.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/custom_text_field.dart';

class LoginModal extends StatefulWidget {
  @override
  _LoginModalState createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  // Controllers for email and password fields
  TextEditingController _emailAddress = TextEditingController();
  TextEditingController _password = TextEditingController();

  // Authentication helper instance
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          // Modal container styling
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 85 / 100,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            // ListView for modal content
            shrinkWrap: true,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            physics: BouncingScrollPhysics(),
            children: [
              Align(
                // Divider line styling
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 35 / 100,
                  margin: EdgeInsets.only(bottom: 20),
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Header text
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                  ),
                ),
              ),
              // Email and Password input fields
              CustomTextField(
                controller: _emailAddress,
                title: 'Email',
                hint: 'youremail@email.com',
              ),
              CustomTextField(
                controller: _password,
                title: 'Password',
                hint: '**********',
                obsecureText: true,
                margin: EdgeInsets.only(top: 16),
              ),
              // Login Button
              Container(
                margin: EdgeInsets.only(top: 32, bottom: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // Get email and password from controllers
                    String email = _emailAddress.text.toString();
                    String password = _password.text.toString();

                    // Check if email and password are not empty
                    if (email.isEmpty || password.isEmpty) {
                      // Show validation error if fields are empty
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Validation Error'),
                            content:
                                Text('Please enter both email and password.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    try {
                      // Attempt to log in with provided credentials
                      await auth.logInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // Login successful, navigate to the next screen
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PageSwitcher(),
                        ),
                      );
                    } catch (e) {
                      // Login failed, show a message using AlertDialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Login Failed'),
                            content: Text('Invalid email or password.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: AppColor.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'inter',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    primary: AppColor.primarySoft,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
