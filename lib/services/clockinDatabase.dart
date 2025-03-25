import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/checkinout.dart';

class DatabaseServicescheckinout {
  final CollectionReference attendanceCollection =
  FirebaseFirestore.instance.collection('checkin');

  // ✅ Add Check-In with employee name
  Future<DocumentReference> addCheckInOutData(CheckInOutDetails details) async {
    return await attendanceCollection.add({
      'name': details.name,                   // Store employee name
      'checkin': details.checkin,
      'checkout': details.checkout,
      'location': details.location ?? '',     // Save location
    });
  }

  // ✅ Update Check-Out
  Future<void> updateCheckOutData(
      String docId, Timestamp checkoutTime, String location) async {
    await attendanceCollection.doc(docId).update({
      'checkout': checkoutTime,
      'checkout_location': location,          // Save check-out location
    });
  }

  // ✅ Retrieve attendance history
  Stream<QuerySnapshot<CheckInOutDetails>> getCheckTime() {
    return attendanceCollection
        .orderBy('checkin', descending: true)
        .withConverter<CheckInOutDetails>(
      fromFirestore: (snapshot, _) => CheckInOutDetails(
        name: snapshot['name'],           // Retrieve employee name
        checkin: snapshot['checkin'],
        checkout: snapshot['checkout'],
        location: snapshot['location']
      ),
      toFirestore: (details, _) => {
        'name': details.name,
        'checkin': details.checkin,
        'checkout': details.checkout,
        'location': details.location,
      },
    )
        .snapshots();
  }
}
