import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'Total employee', count: 0, showAllText: 'Show all'),
                InfoCard(title: 'Total Office', count: 0, showAllText: 'Shwo all'),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  MenuCard(icon: Icons.people, label: 'Employee'),
                  MenuCard(icon: Icons.location_on, label: 'Office'),
                  MenuCard(icon: Icons.assignment, label: 'Report Attendance'),
                  MenuCard(icon: Icons.not_interested, label: 'Report leave'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final int count;
  final String showAllText;

  InfoCard({required this.title, required this.count, required this.showAllText});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(showAllText, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;

  MenuCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context,'employee_details');
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50),
              SizedBox(height: 10),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}