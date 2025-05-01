import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class OfficeSettingsPage extends StatefulWidget {
  @override
  _OfficeSettingsPageState createState() => _OfficeSettingsPageState();
}

class _OfficeSettingsPageState extends State<OfficeSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Office details
  String _officeName = '';
  String _officeAddress = '';
  String _officeContact = '';
  String _officeEmail = '';
  TimeOfDay _workStartTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = TimeOfDay(hour: 17, minute: 0);
  double _lateThreshold = 15.0; // minutes
  double _earlyLeaveThreshold = 15.0; // minutes
  List<String> _workingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  bool _geoFencingEnabled = false;
  double _geoFenceRadius = 100.0; // meters
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadOfficeSettings();
  }

  Future<void> _loadOfficeSettings() async {
    try {
      final doc = await _firestore.collection('office_settings').doc('main').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _officeName = data['officeName'] ?? '';
          _officeAddress = data['officeAddress'] ?? '';
          _officeContact = data['officeContact'] ?? '';
          _officeEmail = data['officeEmail'] ?? '';
          _workStartTime = _parseTime(data['workStartTime'] ?? '09:00');
          _workEndTime = _parseTime(data['workEndTime'] ?? '17:00');
          _lateThreshold = (data['lateThreshold'] ?? 15.0).toDouble();
          _earlyLeaveThreshold = (data['earlyLeaveThreshold'] ?? 15.0).toDouble();
          _workingDays = List<String>.from(data['workingDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
          _geoFencingEnabled = data['geoFencingEnabled'] ?? false;
          _geoFenceRadius = (data['geoFenceRadius'] ?? 100.0).toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load settings: ${e.toString()}')),
      );
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _workStartTime : _workEndTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _workStartTime = picked;
        } else {
          _workEndTime = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('office_settings').doc('main').set({
        'officeName': _officeName,
        'officeAddress': _officeAddress,
        'officeContact': _officeContact,
        'officeEmail': _officeEmail,
        'workStartTime': _formatTime(_workStartTime),
        'workEndTime': _formatTime(_workEndTime),
        'lateThreshold': _lateThreshold,
        'earlyLeaveThreshold': _earlyLeaveThreshold,
        'workingDays': _workingDays,
        'geoFencingEnabled': _geoFencingEnabled,
        'geoFenceRadius': _geoFenceRadius,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _toggleWorkingDay(String day) {
    setState(() {
      if (_workingDays.contains(day)) {
        _workingDays.remove(day);
      } else {
        _workingDays.add(day);
      }
      _workingDays.sort((a, b) => _dayOrder(a).compareTo(_dayOrder(b)));
    });
  }

  int _dayOrder(String day) {
    const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return order.indexOf(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Office Settings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Office Information Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Office Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Office Name',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _officeName,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        onChanged: (value) => _officeName = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Office Address',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _officeAddress,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        onChanged: (value) => _officeAddress = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _officeContact,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        onChanged: (value) => _officeContact = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Office Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _officeEmail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (value) => _officeEmail = value,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Work Hours Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text('Start Time'),
                              subtitle: Text(_workStartTime.format(context)),
                              leading: Icon(Icons.alarm, color: Colors.blueAccent),
                              onTap: () => _selectTime(context, true),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text('End Time'),
                              subtitle: Text(_workEndTime.format(context)),
                              leading: Icon(Icons.alarm_off, color: Colors.blueAccent),
                              onTap: () => _selectTime(context, false),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Working Days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                          return FilterChip(
                            label: Text(day),
                            selected: _workingDays.contains(day),
                            onSelected: (_) => _toggleWorkingDay(day),
                            selectedColor: Colors.blueAccent,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _workingDays.contains(day) ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Attendance Settings Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        title: Text('Late Arrival Threshold'),
                        subtitle: Text('Considered late if arrival is after start time by:'),
                        trailing: DropdownButton<double>(
                          value: _lateThreshold,
                          items: [5.0, 10.0, 15.0, 20.0, 30.0, 60.0].map((value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text('$value minutes'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _lateThreshold = value;
                              });
                            }
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Early Leave Threshold'),
                        subtitle: Text('Considered early leave if departure is before end time by:'),
                        trailing: DropdownButton<double>(
                          value: _earlyLeaveThreshold,
                          items: [5.0, 10.0, 15.0, 20.0, 30.0, 60.0].map((value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text('$value minutes'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _earlyLeaveThreshold = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Location Settings Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Enable Geo-Fencing'),
                        subtitle: Text('Restrict check-in/out to office location'),
                        value: _geoFencingEnabled,
                        onChanged: (value) {
                          setState(() {
                            _geoFencingEnabled = value;
                          });
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      if (_geoFencingEnabled) ...[
                        SizedBox(height: 16),
                        ListTile(
                          title: Text('Geo-Fence Radius'),
                          subtitle: Text('Allowed distance from office for check-in/out'),
                          trailing: DropdownButton<double>(
                            value: _geoFenceRadius,
                            items: [50.0, 100.0, 150.0, 200.0, 250.0, 300.0].map((value) {
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text('$value meters'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _geoFenceRadius = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text('SAVE SETTINGS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}