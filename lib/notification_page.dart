import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int selectedIndex = 0; // Track the selected notification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Notifications'),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: 4, // Replace with the actual number of notifications
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index; // Update selected index
              });
            },
            child: NotificationCard(
              title: 'Leave approval', // Replace with actual notification title
              content: '[content]', // Replace with actual notification content
              relative: '[relative]', // Replace with actual relative time
              isSelected: index == selectedIndex,
            ),
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String content;
  final String relative;
  final bool isSelected;

  NotificationCard({
    required this.title,
    required this.content,
    required this.relative,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.grey[200] : Colors.white,
      child: ListTile(
        leading: Icon(Icons.notifications, color: Colors.red),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            Text(relative, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}