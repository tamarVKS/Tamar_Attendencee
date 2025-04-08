import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/checkinout.dart';

class DatabaseServicescheckinout {
  final CollectionReference attendanceCollection =
  FirebaseFirestore.instance.collection('checkin');

  // ✅ Add Check-In with employee name and location
  Future<DocumentReference> addCheckInOutData(CheckInOutDetails details) async {
    return await attendanceCollection.add(details.toJson());
  }

  // ✅ Update Check-Out time and location
  Future<void> updateCheckOutData(
      String docId, Timestamp checkoutTime, String checkoutLocation) async {
    await attendanceCollection.doc(docId).update({
      'checkout': checkoutTime,
      'checkoutLocation': checkoutLocation,
    });
  }

  // ✅ Retrieve attendance history (stream)
  Stream<QuerySnapshot<CheckInOutDetails>> getCheckTime() {
    return attendanceCollection
        .orderBy('checkin', descending: true)
        .withConverter<CheckInOutDetails>(
      fromFirestore: (snapshot, _) =>
          CheckInOutDetails.fromJson(snapshot.data()!),
      toFirestore: (details, _) => details.toJson(),
    )
        .snapshots();
  }

  // ✅ Retrieve latest check-in for a specific employee
  Stream<QuerySnapshot> getCheckTimeByName(String name) {
    return attendanceCollection
        .where('name', isEqualTo: name)
        .orderBy('checkin', descending: true)
        .limit(1)
        .snapshots();
  }
}
