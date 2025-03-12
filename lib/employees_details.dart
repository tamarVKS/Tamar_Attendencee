import 'package:flutter/material.dart';



class EmployeeScreens extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Employee'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '');
              // Add employee action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 4, // Replace with the actual number of employees
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('[display_name]'), // Replace with employee name
                  subtitle: Text('[level]'), // Replace with employee level
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to employee details
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}