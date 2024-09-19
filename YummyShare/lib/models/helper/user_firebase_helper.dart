// Importing necessary packages and local dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummyshare/models/core/yummy_user_info.dart';

// Helper class for interacting with Cloud Firestore to manage user data
class user_firebase_helper {
  // Collection reference for the "YummyUsers" collection in Cloud Firestore
  final CollectionReference yummyUsersCollection =
      FirebaseFirestore.instance.collection("YummyUsers");

  // Stream method to get user information by user ID from Cloud Firestore
  Stream<List<YummyUserInfo>> getUserInfo(String userID) {
    return yummyUsersCollection
        .where("id", isEqualTo: userID)
        .snapshots()
        .map((querySnapshot) {
      List<YummyUserInfo> yummyUsers = [];

      // Iterating through each document in the query snapshot
      querySnapshot.docs.forEach((doc) {
        // Creating a YummyUserInfo object from the document snapshot and adding it to the list
        yummyUsers.add(YummyUserInfo.fromSnapshot(doc));
      });

      return yummyUsers;
    });
  }

  // Future method to create a user in Cloud Firestore
  Future<void> createUser(YummyUserInfo yummyUser) {
    return yummyUsersCollection.add(yummyUser.toMap());
  }

  // Future method to update a user in Cloud Firestore
  Future<void> updateUser(YummyUserInfo yummyUser) {
    return yummyUser.reference!.update(yummyUser.toMap());
  }

  // Future method to delete a user from Cloud Firestore
  Future<void> deleteUser(YummyUserInfo yummyUser) {
    return yummyUser.reference!.delete();
  }

  // Future method to update a user's profile photo in Cloud Firestore
  Future<void> updateUserPhoto(
      YummyUserInfo yummyUser, String newProfileImage) {
    // Updating the user's profile image attribute
    yummyUser.profile_image = newProfileImage;
    return yummyUser.reference!.update(yummyUser.toMap());
  }
}
