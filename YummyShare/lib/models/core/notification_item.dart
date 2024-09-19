// Importing the necessary package for Firebase authentication
import 'package:firebase_auth/firebase_auth.dart';

// Getting the current user from Firebase authentication
User? user = FirebaseAuth.instance.currentUser;

// A class representing a notification item
class NotificationItem {
  String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  // Constructor for creating a new NotificationItem
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });

  // Method to convert the NotificationItem to a map (for storing in a database, for example)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'isRead': isRead ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Factory method to create a NotificationItem from a map
  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      isRead: map['isRead'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
