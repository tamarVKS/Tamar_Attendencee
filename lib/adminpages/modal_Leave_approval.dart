import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveApprovalScreen extends StatefulWidget {
  @override
  _LeaveApprovalScreenState createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  // Stream to listen for leave requests with "Pending" status
  Stream<QuerySnapshot> _leaveRequestsStream = FirebaseFirestore.instance
      .collection('leave_requests')
      .where('status', isEqualTo: 'Pending')
      .snapshots();

  Future<void> updateLeaveStatus(String requestId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(requestId)
        .update({'status': newStatus});
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Approval', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _leaveRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No pending leave requests'));

          final leaveRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              final doc = leaveRequests[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Employee ID: ${data['employeeId']}", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Leave Type: ${data['type']}"),
                      Text("Start Date: ${formatDate(data['startDate'])}"),
                      Text("End Date: ${formatDate(data['endDate'])}"),
                      Text("Days: ${data['days']}"),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => updateLeaveStatus(data['id'], 'Rejected'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: Icon(Icons.cancel, color: Colors.white),
                            label: Text("Reject"),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => updateLeaveStatus(data['id'], 'Approved'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            icon: Icon(Icons.check_circle, color: Colors.white),
                            label: Text("Approve"),
                          ),
                        ],
                      )
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
