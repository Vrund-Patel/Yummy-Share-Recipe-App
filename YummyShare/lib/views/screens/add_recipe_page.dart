import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/local_recipe_database_helper.dart';
import 'package:yummyshare/models/helper/local_notification_helper.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/screens/page_switcher.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/models/core/notification_item.dart';
import 'package:yummyshare/models/helper/notification_database_helper.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

// Define the AddRecipe class
class AddRecipe extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

// Define the state class for AddRecipe
class _AddRecipePageState extends State<AddRecipe> {
  // Initialize variables and controllers
  User? user = FirebaseAuth.instance.currentUser;
  bool _isButtonDisabled = false;
  String? _base64Image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firebaseHelper = RecipeFireStoreHelper();
  final db_helper = LocalRecipeDBHelper();
  final notification_db_helper = Notification_DB_helper();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _cookTimeController = TextEditingController();
  List<CameraDescription>? cameras;
  CameraController? _cameraController;
  int serves = 1;
  XFile? _recipeImage;

  List<IngredientsController> ingredientsControllers = [
    IngredientsController(),
  ];
  List<InstructionsController> instructionsControllers = [
    InstructionsController(),
  ];

  // Initialize the camera and dispose it when not needed
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Initialize the camera
  void _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController =
          CameraController(cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
    }
  }

  // Increment and decrement serves
  void _incrementServes() {
    setState(() {
      serves++;
    });
  }

  void _decrementServes() {
    if (serves > 1) {
      setState(() {
        serves--;
      });
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    if (_isButtonDisabled) {
      return;
    }

    setState(() {
      _isButtonDisabled = true;
    });

    final imagePicker = ImagePicker();

    try {
      final pickedImage =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        // Read the image as bytes
        List<int> imageBytes = await pickedImage.readAsBytes();

        // Resize the image
        img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
        img.Image resizedImage = img.copyResize(image!, width: 500);

        // Encode the resized image back to bytes
        List<int> resizedBytes = img.encodePng(resizedImage);

        String base64Image = base64Encode(resizedBytes);

        setState(() {
          _recipeImage = pickedImage;
          _base64Image = base64Image;
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }

    setState(() {
      _isButtonDisabled = false;
    });
  }

  // Pick an image from the camera
  Future<void> _pickImageFromCamera() async {
    if (_isButtonDisabled) {
      return;
    }

    setState(() {
      _isButtonDisabled = true;
    });

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        List<int> imageBytes = await pickedImage.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        setState(() {
          _recipeImage = pickedImage;
          _base64Image = base64Image;
        });
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }

    setState(() {
      _isButtonDisabled = false;
    });
  }

  // Build the ingredient fields dynamically
  Widget _buildIngredientFields() {
    return ListView.builder(
      itemCount: ingredientsControllers.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final ingredientController = ingredientsControllers[index];
        return Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: ingredientController.nameController,
                decoration: InputDecoration(labelText: 'Ingredient'),
                validator: (value) {
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: ingredientController.amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  return null;
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  ingredientsControllers.removeAt(index);
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Add a new ingredient field
  void _addIngredient() {
    setState(() {
      ingredientsControllers.add(IngredientsController());
    });
  }

  // Build the instruction fields dynamically
  Widget _buildInstructionsFields() {
    return ListView.builder(
      itemCount: instructionsControllers.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final instructionsController = instructionsControllers[index];
        return Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: instructionsController.stepController,
                decoration: InputDecoration(labelText: 'Step'),
                validator: (value) {
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: instructionsController.bodyController,
                decoration: InputDecoration(labelText: 'Instruction'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  instructionsControllers.removeAt(index);
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Add a new instruction field
  void _addInstruction() {
    setState(() {
      instructionsControllers.add(InstructionsController());
    });
  }

  // Build the UI for adding a recipe
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text(
          'Add Recipe',
          style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (_recipeImage != null)
                Image.file(
                  File(_recipeImage!.path),
                  height: 200,
                  width: 200,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _pickImage();
                    },
                    child: Text('Pick Recipe Image'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(AppColor.primary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_a_photo_outlined),
                    onPressed: () async {
                      await _pickImageFromCamera();
                    },
                  ),
                ],
              ),
              // Form fields for recipe details
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Recipe Description'),
                validator: (value) {
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Text('Serves: $serves'),
                  IconButton(
                    onPressed: _decrementServes,
                    icon: Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: _incrementServes,
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              TextFormField(
                controller: _cookTimeController,
                decoration:
                    InputDecoration(labelText: 'Cook Time (in minutes)'),
                validator: (value) {
                  return null;
                },
              ),
              // Ingredient and instruction fields
              _buildIngredientFields(),
              TextButton(
                onPressed: _addIngredient,
                child: Text('Add Ingredient'),
              ),
              _buildInstructionsFields(),
              TextButton(
                onPressed: _addInstruction,
                child: Text('Add Instruction'),
              ),
              // Button to submit the recipe
              Container(
                margin: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate form and submit recipe
                    if (_formKey.currentState!.validate()) {
                      // Retrieve and format recipe data
                      String title = _titleController.text;
                      String description = _descriptionController.text;
                      String cookTime = _cookTimeController.text;
                      String photo = _base64Image!;

                      List<Ingredient> recipeIngredients =
                          ingredientsControllers.map((controller) {
                        return Ingredient(
                          name: controller.nameController.text,
                          size: controller.amountController.text,
                        );
                      }).toList();
                      List<Instructions> recipeInstructions =
                          instructionsControllers.map((controller) {
                        return Instructions(
                          number: controller.stepController.text,
                          body: controller.bodyController.text,
                        );
                      }).toList();
                      Recipe newRecipe = Recipe(
                        id: user!.uid,
                        title: title,
                        photo: photo,
                        time: cookTime,
                        description: description,
                        servings: serves,
                        saveCount: 0,
                        ingredients: recipeIngredients,
                        instructions: recipeInstructions,
                      );

                      // Save recipe to Firebase
                      firebaseHelper.createRecipe(newRecipe);

                      // Show notification
                      NotificationHelper().showNotification(
                          title: 'Yummy Share', body: 'Recipe Added');

                      // Save notification to local database
                      NotificationItem newItem = NotificationItem(
                          id: user!.uid,
                          title: newRecipe.title,
                          message:
                              "${newRecipe.title} has been created successfully",
                          isRead: false,
                          timestamp: DateTime.now());

                      notification_db_helper.insertNotification(newItem);

                      // Show success message and navigate to home
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Recipe added successfully'),
                        ),
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PageSwitcher(),
                        ),
                      );
                    }
                  },
                  child: Text('Add Recipe'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColor.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for managing ingredient controllers
class IngredientsController {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
}

// Helper class for managing instruction controllers
class InstructionsController {
  TextEditingController stepController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
}
