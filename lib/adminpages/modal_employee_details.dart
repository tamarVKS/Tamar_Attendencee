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
      appBar: AppBar(backgroundColor: Colors.blueAccent, title: Text('Employees'),
          actions: [IconButton(icon: Icon(Icons.add), onPressed: _navigateToAddEmployee)]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Search', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('employees').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No employees found'));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var employee = snapshot.data!.docs[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: employee['imageUrl'] != '' ? NetworkImage(employee['imageUrl']) : null, child: employee['imageUrl'] == '' ? Icon(Icons.person) : null),
                      title: Text(employee['name'] ?? 'Unknown'),
                      subtitle: Text(employee['jobTitle'] ?? 'No title'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => Navigator.pushNamed(context, '/personalInformation', arguments: employee.id),
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
