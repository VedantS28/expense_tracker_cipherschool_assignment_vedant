import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  NotificationProvider() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch budget alerts from Firestore
        final budgetAlertsSnapshot = await _firestore
            .collection('budgetAlerts')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

        // Transform the budget alerts into the notification format
        final List<Map<String, dynamic>> fetchedNotifications = [];

        for (var doc in budgetAlertsSnapshot.docs) {
          final data = doc.data();
          fetchedNotifications.add({
            'id': doc.id,
            'title': 'Budget Alert: ${data['category']}',
            'message':
                'You\'ve used ${data['percentUsed']}% of your ${data['category']} budget. '
                    'Spent ₹${data['spentAmount'].toStringAsFixed(0)} of ₹${data['budgetAmount'].toStringAsFixed(0)}.',
            'date': data['timestamp'] ?? Timestamp.now(),
            'read': data['read'] ?? false,
            'type': data['percentUsed'] >= 100 ? 'warning' : 'info',
            'budgetId': data['budgetId'],
          });
        }

        // Also fetch other app notifications
        final appNotificationsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        for (var doc in appNotificationsSnapshot.docs) {
          final data = doc.data();
          fetchedNotifications.add({
            'id': doc.id,
            'title': data['title'] ?? 'Notification',
            'message': data['message'] ?? '',
            'date': data['timestamp'] ?? Timestamp.now(),
            'read': data['read'] ?? false,
            'type': data['type'] ?? 'info',
          });
        }

        // Sort all notifications by date
        fetchedNotifications.sort((a, b) {
          final aDate = (a['date'] as Timestamp).toDate();
          final bDate = (b['date'] as Timestamp).toDate();
          return bDate.compareTo(aDate);
        });

        notifications = fetchedNotifications;
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      notifications = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(Map<String, dynamic> notification) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final String id = notification['id'];
      final String budgetId = notification['budgetId'] ?? '';

      if (budgetId.isNotEmpty) {
        // This is a budget alert
        await _firestore.collection('budgetAlerts').doc(id).update({
          'read': true,
        });
      } else {
        // This is a general app notification
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(id)
            .update({
          'read': true,
        });
      }

      // Update the local notification state
      final index = notifications.indexOf(notification);
      if (index != -1) {
        notifications[index]['read'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Create a batch to handle multiple updates
      final batch = _firestore.batch();

      for (var notification in notifications) {
        if (notification['read'] == false) {
          final String id = notification['id'];
          final String budgetId = notification['budgetId'] ?? '';

          if (budgetId.isNotEmpty) {
            // Budget alert
            final docRef = _firestore.collection('budgetAlerts').doc(id);
            batch.update(docRef, {'read': true});
          } else {
            // App notification
            final docRef = _firestore
                .collection('users')
                .doc(userId)
                .collection('notifications')
                .doc(id);
            batch.update(docRef, {'read': true});
          }
        }
      }

      await batch.commit();

      // Update all notifications to be read
      notifications = notifications.map((notification) {
        notification['read'] = true;
        return notification;
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
