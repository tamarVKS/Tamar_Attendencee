import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  Future<void> _navigateToAddEmployee() async {
    final result = await Navigator.pushNamed(context, '/modal_employee_form');
    if (result == true) setState(() {}); // Refresh after adding an employee
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Employees'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _navigateToAddEmployee)
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
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('employees').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No employees found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var employee = snapshot.data!.docs[index];
                    var data = employee.data() as Map<String, dynamic>?; // ✅ Ensure it's a map

                    String name = data?['name'] ?? 'Unknown';
                    String jobTitle = data?['jobTitle'] ?? 'No title';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(name),
                      subtitle: Text(jobTitle),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => Navigator.pushNamed(
                          context, '/personalInformation',
                          arguments: employee.id),
                    );
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
