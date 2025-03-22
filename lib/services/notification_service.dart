import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Channel IDs
  final String _budgetChannelId = 'budget_alerts_channel';
  final String _budgetChannelName = 'Budget Alerts';
  final String _budgetChannelDescription =
      'Notifications for budget thresholds and alerts';

  // Initialize notification services
  Future<void> initialize() async {
    // Request permission for notifications (more explicit permissions)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Setup notification channels for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'budget_alerts_channel', 
      'Budget Alerts', 
      description:
          'Notifications for budget thresholds and alerts', 
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Register the channel with the system
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
        // Handle notification tap here
      },
    );

    // Get FCM token and save to Firestore
    String? token = await _messaging.getToken();
    _saveTokenToFirestore(token);

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // For handling notification when app is in terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      // Handle the initial message if needed
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM Token saved: $token');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Budget Alert',
        notification.body ?? 'Check your budget status',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _budgetChannelId,
            _budgetChannelName,
            channelDescription: _budgetChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            showWhen: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // Send local notification for budget threshold
  Future<void> showBudgetAlert({
    required String title,
    required String body,
  }) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _budgetChannelId,
            _budgetChannelName,
            channelDescription: _budgetChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF673AB7),
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      debugPrint('Local notification sent: $title');
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Log budget alert to Firestore for history
  Future<void> logBudgetAlert({
    required String budgetId,
    required String category,
    required double budgetAmount,
    required double spentAmount,
    required int percentUsed,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('budgetAlerts').add({
        'userId': userId,
        'budgetId': budgetId,
        'category': category,
        'budgetAmount': budgetAmount,
        'spentAmount': spentAmount,
        'percentUsed': percentUsed,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Budget alert logged to Firestore');
    } catch (e) {
      debugPrint('Error logging budget alert: $e');
    }
  }
}


