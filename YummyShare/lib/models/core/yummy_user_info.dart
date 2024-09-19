// Importing necessary packages for Firestore and Firebase authentication
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Class representing user information for the "Yummy" app
class YummyUserInfo {
  String id = FirebaseAuth.instance.currentUser!.uid;
  String name;
  String profile_image;
  String profile_name;
  DateTime? signUpDate;
  late DocumentReference? reference;

  // Constructor for creating a YummyUserInfo instance
  YummyUserInfo({
    required this.id,
    required this.name,
    required this.profile_image,
    required this.profile_name,
    this.signUpDate,
    this.reference,
  });

  // Factory method to create a YummyUserInfo instance from JSON data
  factory YummyUserInfo.fromJson(Map<String, Object> json) {
    return YummyUserInfo(
      id: json["id"] as String? ?? "",
      name: json["name"] as String? ?? "",
      profile_image: json["profile_image"] as String? ?? "",
      profile_name: json["profile_name"] as String? ?? "",
      signUpDate: json["signUpDate"] as DateTime?,
    );
  }

  // Factory method to create a YummyUserInfo instance from a Firestore document map
  factory YummyUserInfo.fromMap(
      Map<String, dynamic> map, DocumentReference reference) {
    return YummyUserInfo(
      id: map['id'],
      name: map['name'],
      profile_image: map['profile_image'],
      profile_name: map['profile_name'],
      signUpDate: map['signUpDate'],
      reference: reference,
    );
  }

  // Factory method to create a YummyUserInfo instance from a Firestore document snapshot
  factory YummyUserInfo.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw FormatException("Document data is null");
    }

    YummyUserInfo user = YummyUserInfo(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      profile_image: data['profile_image'] as String? ?? '',
      profile_name: data['profile_name'] as String? ?? '',
      signUpDate: data['signUpDate'] as DateTime?,
      reference: doc.reference,
    );
    return user;
  }

  // Method to convert a YummyUserInfo instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profile_image': profile_image,
      'profile_name': profile_name,
      'signUpDate': signUpDate,
    };
  }
}
