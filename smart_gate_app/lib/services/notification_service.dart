import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/notification.dart' as app_notification;

class NotificationService with ChangeNotifier {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('notifications');

  List<app_notification.Notification> _notifications = [];

  List<app_notification.Notification> get notifications => _notifications;

  NotificationService() {
    _loadNotifications();
  }

  void _loadNotifications() {
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _notifications = data.values.map((value) {
          return app_notification.Notification(
            title: value['title'],
            body: value['body'],
            timestamp: DateTime.parse(value['timestamp']),
          );
        }).toList();
        notifyListeners();
      }
    });
  }

  Future<void> addNotification(String title, String body) async {
    final newNotification = app_notification.Notification(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    // try {
    //   await _databaseReference.push().set({
    //     'title': title,
    //     'body': body,
    //     'timestamp': newNotification.timestamp.toIso8601String(),
    //   });
    //   _notifications.add(newNotification);
    //   notifyListeners();
    // } catch (error) {
    //   print('Failed to add notification: $error');
    // }
  }
}
