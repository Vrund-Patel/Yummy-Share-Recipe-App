import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/models/core/notification_item.dart';
import 'package:yummyshare/models/helper/notification_database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationListPage extends StatefulWidget {
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late Stream<List<NotificationItem>> _streamBuilder;
  final db = Notification_DB_helper();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    db.initDatabase();
  }

  _deleteAllNotifications(Stream<List<NotificationItem>> _streamBuilder) {
    _streamBuilder.listen((data) {
      setState(() {
        data.forEach((notification) {
          if (notification.id == user!.uid) {
            db.deleteNotification(notification);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _streamBuilder = db.getAllNotifications().asStream();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification List',
          style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColor.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _streamBuilder = db.getAllNotifications().asStream();
              _deleteAllNotifications(_streamBuilder);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _streamBuilder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<NotificationItem> notifications = snapshot.data!
              .where((notification) => notification.id == user!.uid)
              .toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final id = notification.id;
              final title = notification.title;
              final message = notification.message;
              final formattedTimestamp = notification.timestamp.toString();

              return Card(
                margin: EdgeInsets.all(8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        message,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Timestamp: $formattedTimestamp',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
