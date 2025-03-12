import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tamar_attendence/models/attendancedetails.dart';

const String attendanceHistory = "AttendanceHistory"; // Fixed typo

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<AttendanceDetails> _collectionReference;

  DatabaseService() {
    _collectionReference = _firestore.collection(attendanceHistory).withConverter<AttendanceDetails>(
      fromFirestore: (snapshot, _) => AttendanceDetails.fromJson(snapshot.data()!),
      toFirestore: (attendanceDetails, _) => attendanceDetails.toJson(), // Fixed parameter naming
    );
  }

  Stream<QuerySnapshot<AttendanceDetails>> getName() {
    return _collectionReference.snapshots();
  }

  Future<void> addData(AttendanceDetails attendanceDetails) async {
    await _collectionReference.add(attendanceDetails); // Using correct model type
  }
}
