import 'package:expense_tracker_cipherschool_assignment/viewmodels/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: NotificationScreenContent(),
    );
  }
}

class NotificationScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.deepPurple),
            onPressed: () => provider.loadNotifications(),
          ),
          IconButton(
            icon: Icon(Icons.done_all, color: Colors.deepPurple),
            onPressed: () => provider.markAllAsRead(),
          ),
        ],
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(context, provider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationProvider provider) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: provider.notifications.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        final isRead = notification['read'] as bool;
        final type = notification['type'] as String;
        final date = (notification['date'] as Timestamp).toDate();
        
        // Determine icon and color based on notification type
        IconData icon;
        Color color;
        
        switch (type) {
          case 'warning':
            icon = Icons.warning_amber_rounded;
            color = Colors.orange;
            break;
          case 'success':
            icon = Icons.check_circle_outline;
            color = Colors.green;
            break;
          case 'info':
          default:
            icon = Icons.info_outline;
            color = Colors.deepPurple;
            break;
        }
        
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  provider.formatDate(date),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Mark as read when tapped
              if (!isRead) {
                provider.markAsRead(notification);
              }
              
              // Show notification details or perform action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification: ${notification['title']}'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }
}