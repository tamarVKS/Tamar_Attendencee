import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveManagementScreen extends StatefulWidget {
  @override
  _LeaveManagementScreenState createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  List<Map<String, String>> leaveRequests = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLeaveType;
  int totalLeave = 12;
  int availableLeave = 12;

  void _showLeaveRequestDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Request Leave', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Start Date & End Date in One Line
                  Row(
                    children: [
                      // Start Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _startDate = pickedDate;
                                _endDate = null; // Reset end date
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startDate == null ? 'Start Date' : DateFormat('yyyy-MM-dd').format(_startDate!),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today, color: Colors.blueAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),

                      // End Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: _startDate == null
                              ? null
                              : () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _startDate!,
                              firstDate: _startDate!,
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _endDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate == null ? 'End Date' : DateFormat('yyyy-MM-dd').format(_endDate!),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today, color: Colors.blueAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Leave Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedLeaveType,
                    hint: Text('Select Leave Type'),
                    items: ['Sick Leave', 'Casual Leave', 'Medical Leave']
                        .map((leaveType) => DropdownMenuItem(value: leaveType, child: Text(leaveType)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    onPressed: _submitLeaveRequest,
                    child: Text('Submit Request', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _submitLeaveRequest() {
    if (_startDate == null || _endDate == null || _selectedLeaveType == null) return;

    int leaveDays = _endDate!.difference(_startDate!).inDays + 1;
    if (leaveDays > 0 && leaveDays <= availableLeave) {
      setState(() {
        leaveRequests.add({
          'dateRange': '${DateFormat('yyyy-MM-dd').format(_startDate!)} to ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
          'type': _selectedLeaveType!,
          'days': leaveDays.toString(),
          'status': 'Pending',
        });
        availableLeave -= leaveDays;
      });
    }

    _startDate = null;
    _endDate = null;
    _selectedLeaveType = null;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showLeaveRequestDialog),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LeaveCard(color: Colors.brown, title: 'Total Leave', count: totalLeave),
                LeaveCard(color: Colors.teal, title: 'Available Leave', count: availableLeave),
              ],
            ),
            SizedBox(height: 20),
            Center(child: Text('Leave Request History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: leaveRequests.length,
                itemBuilder: (context, index) {
                  return LeaveRequestCard(
                    dateRange: leaveRequests[index]['dateRange']!,
                    type: leaveRequests[index]['type']!,
                    status: leaveRequests[index]['status']!,
                    days: leaveRequests[index]['days']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LeaveCard extends StatelessWidget {
  final Color color;
  final String title;
  final int count;

  LeaveCard({required this.color, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class LeaveRequestCard extends StatelessWidget {
  final String dateRange;
  final String type;
  final String status;
  final String days;

  LeaveRequestCard({required this.dateRange, required this.type, required this.status, required this.days});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$dateRange - $type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('Days: $days', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Status: $status', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
