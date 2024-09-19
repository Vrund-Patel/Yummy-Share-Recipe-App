import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yummyshare/views/screens/page_switcher.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/custom_text_field.dart';
import 'package:yummyshare/views/widgets/modals/login_modal.dart';
import 'package:yummyshare/models/helper/auth.dart';
import 'package:yummyshare/models/core/yummy_user_info.dart';
import 'package:yummyshare/models/helper/user_firebase_helper.dart';

class RegisterModal extends StatefulWidget {
  @override
  _RegisterModalState createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  // Controllers for various text input fields
  TextEditingController _emailAddress = TextEditingController();
  TextEditingController _userName = TextEditingController();
  TextEditingController _fullName = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _retypePassword = TextEditingController();

  // Authentication and user helper instances
  final Auth auth = Auth();
  final user_firebase_helper user_helper = user_firebase_helper();

  // Function to handle the registration process
  Future<void> signUp() async {
    // Check if the entered passwords match
    if (_password.text == _retypePassword.text) {
      try {
        // Attempt to sign up with email and password
        await auth.signUpWithEmailAndPassword(
          email: _emailAddress.text,
          password: _password.text,
        );

        // Update user display name and reload user data
        await auth.currentUser!.updateDisplayName(_userName.text);
        await auth.currentUser!.reload();

        // Create a new user object with additional details
        YummyUserInfo newUser = YummyUserInfo(
          id: auth.currentUser!.uid,
          name: _fullName.text,
          profile_image: auth.currentUser!.photoURL.toString(),
          profile_name: _userName.text,
        );

        // Store the user details in the database
        user_helper.createUser(newUser);

        // Navigate to the next screen on successful registration
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PageSwitcher(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // Handle specific registration exceptions
        if (e.code == 'weak-password') {
          // Show a dialog for weak password error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registration Failed'),
                content: Text('The password provided is too weak.'),
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
        } else if (e.code == 'email-already-in-use') {
          // Show a dialog for email already in use error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registration Failed'),
                content: Text('The account already exists for that email.'),
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
        } else {
          print(e.code);
        }
      } catch (e) {
        // Handle other exceptions
        print(e);
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginModal(),
          ),
        );
      }
    } else {
      // Show a dialog for password mismatch error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Validation Error'),
            content: Text('Passwords do not match.'),
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
  }

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
                  'Get Started',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                  ),
                ),
              ),
              // Form
              CustomTextField(
                controller: _emailAddress,
                title: 'Email',
                hint: 'youremail@email.com',
              ),
              CustomTextField(
                controller: _fullName,
                title: 'Full Name',
                hint: 'Your Full Name',
                margin: EdgeInsets.only(top: 16),
              ),
              CustomTextField(
                controller: _userName,
                title: 'User Name',
                hint: 'Your User Name',
                margin: EdgeInsets.only(top: 16),
              ),
              CustomTextField(
                controller: _password,
                title: 'Password',
                hint: '**********',
                obsecureText: true,
                margin: EdgeInsets.only(top: 16),
              ),
              CustomTextField(
                controller: _retypePassword,
                title: 'Retype Password',
                hint: '**********',
                obsecureText: true,
                margin: EdgeInsets.only(top: 16),
              ),
              // Register Button
              Container(
                margin: EdgeInsets.only(top: 32, bottom: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: signUp,
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'inter',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    primary: AppColor.primary,
                  ),
                ),
              ),
              // Login textbutton
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) {
                      return LoginModal();
                    },
                  );
                },
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Have an account? ',
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'inter',
                        ),
                        text: 'Log in',
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
