import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTimeRange? selectedDateRange;

  final Color primaryColor = Color(0xFF0D1B2A); // Dark background
  final Color cardColor = Color(0xFF1B263B); // Card dark blue
  final Color accentColor = Color(0xFFFFC107); // Gold/yellow accent
  final Color textLightColor = Colors.white;
  final Color fadedTextColor = Colors.grey.shade400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: TextStyle(fontWeight: FontWeight.bold, color: textLightColor),
        ),
        backgroundColor: cardColor,
        centerTitle: true,
        elevation: 4,
        iconTheme: IconThemeData(color: accentColor),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_rounded, color: accentColor),
            onPressed: () async {
              DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
                initialDateRange: selectedDateRange,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: accentColor,
                        onPrimary: Colors.black,
                        surface: cardColor,
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: primaryColor,
                      textTheme: TextTheme(
                        bodyLarge: TextStyle(color: Colors.white),
                        bodyMedium: TextStyle(color: Colors.white70),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  selectedDateRange = picked;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: accentColor),
            onPressed: _generateAndDownloadPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedDateRange != null)
            Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}',
                      style: TextStyle(color: textLightColor, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () => setState(() => selectedDateRange = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .orderBy('checkin', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: accentColor));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No attendance history found.", style: TextStyle(color: fadedTextColor)),
                  );
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  DateTime checkIn = (data['checkin'] as Timestamp).toDate();
                  if (selectedDateRange != null) {
                    return checkIn.isAfter(selectedDateRange!.start.subtract(Duration(days: 1))) &&
                        checkIn.isBefore(selectedDateRange!.end.add(Duration(days: 1)));
                  }
                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text("No records in selected date range.", style: TextStyle(color: fadedTextColor)),
                  );
                }

                Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};
                for (var doc in filteredDocs) {
                  var data = doc.data() as Map<String, dynamic>;
                  DateTime checkIn = (data['checkin'] as Timestamp).toDate();
                  String formattedDate = DateFormat('EEE, dd MMM yyyy').format(checkIn);
                  groupedByDate.putIfAbsent(formattedDate, () => []).add(doc);
                }

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: groupedByDate.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                        ...entry.value.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          DateTime checkInTime = (data['checkin'] as Timestamp).toDate();
                          DateTime? checkOutTime = data['checkout'] != null
                              ? (data['checkout'] as Timestamp).toDate()
                              : null;

                          return AttendanceCard(
                            name: data['employee_name'] ?? 'N/A',
                            clockIn: DateFormat('hh:mm a').format(checkInTime),
                            clockOut: checkOutTime != null
                                ? DateFormat('hh:mm a').format(checkOutTime)
                                : 'Not checked out',
                            checkInLocation: data['checkin_location'] ?? 'Unknown',
                            checkOutLocation: data['checkout_location'] ?? 'Not checked out',
                            cardColor: cardColor,
                            accentColor: accentColor,
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdf = pw.Document();
    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .orderBy('checkin', descending: true)
        .get();

    final filteredDocs = snapshot.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime checkIn = (data['checkin'] as Timestamp).toDate();
      if (selectedDateRange != null) {
        return checkIn.isAfter(selectedDateRange!.start.subtract(Duration(days: 1))) &&
            checkIn.isBefore(selectedDateRange!.end.add(Duration(days: 1)));
      }
      return true;
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "MyCompany Attendance Report",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              "Generated on ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}",
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Name', 'Clock In', 'Clock Out', 'Check-In Location', 'Check-Out Location'],
            data: filteredDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              DateTime checkIn = (data['checkin'] as Timestamp).toDate();
              DateTime? checkOut = data['checkout'] != null ? (data['checkout'] as Timestamp).toDate() : null;

              return [
                DateFormat('dd MMM yyyy').format(checkIn),
                data['employee_name'] ?? 'N/A',
                DateFormat('hh:mm a').format(checkIn),
                checkOut != null ? DateFormat('hh:mm a').format(checkOut) : 'N/A',
                data['checkin_location'] ?? 'N/A',
                data['checkout_location'] ?? 'N/A',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final fileName = 'MyCompany_AttendanceReport_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String name;
  final String clockIn;
  final String clockOut;
  final String checkInLocation;
  final String checkOutLocation;
  final Color cardColor;
  final Color accentColor;

  const AttendanceCard({
    required this.name,
    required this.clockIn,
    required this.clockOut,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Clock In: $clockIn", style: TextStyle(color: accentColor)),
                Text("Clock Out: $clockOut", style: TextStyle(color: accentColor)),
              ],
            ),
            SizedBox(height: 8),
            Text("Check-In Location: $checkInLocation", style: TextStyle(color: Colors.grey[300])),
            Text("Check-Out Location: $checkOutLocation", style: TextStyle(color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }
}
