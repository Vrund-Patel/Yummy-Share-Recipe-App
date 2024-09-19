import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/core/yummy_user_info.dart';
import 'package:yummyshare/models/helper/local_recipe_database_helper.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/models/helper/user_firebase_helper.dart';
import 'package:yummyshare/views/screens/auth/welcome_page.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/recipe_tile.dart';
import 'package:yummyshare/models/helper/dataTableDialog.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? _base64image =
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=";
  final db_helper = LocalRecipeDBHelper();
  final user_helper = user_firebase_helper();
  final firestore_helper = RecipeFireStoreHelper();
  late Stream<List<Recipe>> _streamBuilder;
  late Stream<List<YummyUserInfo>> cur_user;
  late List<RecipeTableInfo> recipes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();

      // Resize the image
      img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
      img.Image resizedImage = img.copyResize(image!, width: 500);

      // Encode the resized image back to bytes
      List<int> resizedBytes = img.encodePng(resizedImage);
      final base64Image = base64Encode(resizedBytes);

      Stream<List<YummyUserInfo>> cur_user = user_helper.getUserInfo(user!.uid);
      cur_user.listen((data) {
        setState(() {
          data.forEach((userInDatabase) {
            if (userInDatabase.id == user!.uid) {
              user_helper.updateUserPhoto(userInDatabase, base64Image);
            }
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cur_user = user_helper.getUserInfo(user!.uid);
    _streamBuilder = firestore_helper.getAllRecipes();
    recipes = [];

    cur_user.listen((data) {
      if (data.isNotEmpty && data[0].id == user!.uid) {
        if (data[0].profile_image != "null" &&
            data[0].profile_image != _base64image) {
          setState(() {
            _base64image = data[0].profile_image;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _streamBuilder.listen((data) {
      recipes.clear();
      data.forEach((recipe) {
        if (recipe.id == user!.uid) {
          recipes.add(RecipeTableInfo(recipe.title, recipe.saveCount));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'inter',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: AppColor.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              RecipeDialog.showRecipeTableDialog(context, recipes);
            },
            icon: Icon(
              Icons.show_chart,
              color: AppColor.primary,
              size: 24,
            ),
          ),
          TextButton(
            onPressed: () {
              // Log out the user when the button is pressed
              FirebaseAuth.instance.signOut();
              // Navigate to the login or home screen after logging out
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  _pickImage();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipOval(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            image: _base64image != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      Base64Decoder().convert(_base64image!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SvgPicture.asset(
                      'assets/icons/camera.svg',
                      color: AppColor.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: StreamBuilder<List<YummyUserInfo>>(
                stream: cur_user,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No user data found.');
                  } else {
                    YummyUserInfo userInfo = snapshot.data!.first;

                    return Column(
                      children: [
                        Text(
                          '${userInfo.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary,
                          ),
                        ),
                        Text(
                          'Email: ${user!.email}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          16), // Add this line for left and right padding
                  child: StreamBuilder<List<Recipe>>(
                    stream: _streamBuilder,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No recipes available.');
                      } else {
                        List<Recipe> userRecipes = snapshot.data!
                            .where((recipe) => recipe.id == user!.uid)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Posts',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: userRecipes.length,
                              itemBuilder: (context, index) {
                                if (index >= 0 && index < userRecipes.length) {
                                  return RecipeTile(
                                    data: userRecipes[index],
                                  );
                                } else {
                                  return Text("Out of Range");
                                }
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
