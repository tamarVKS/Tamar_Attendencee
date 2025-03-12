import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/checkin_details.dart';
import 'package:tamar_attendence/models/checkout_details.dart';

const String timingCollection = "clockIn";
const String timingCollection1 = "clockOut";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<CheckIn> _checkInCollection;

  DatabaseService() {
    _checkInCollection =
        _firestore.collection(timingCollection).withConverter<CheckIn>(
          fromFirestore: (snapshot, _) => CheckIn.fromJson(snapshot.data()!),
          toFirestore: (checkIn, _) => checkIn.toJson(),
        );
  }

  /// Stream to get all check-in records
  Stream<QuerySnapshot<CheckIn>> getCheckIns() {
    return _checkInCollection.snapshots();
  }

  /// Add a new check-in record
  Future<void> addCheckIn(CheckIn checkIn) async {
    await _checkInCollection.add(checkIn);
  }

  /// Update an existing check-in record
  Future<void> updateCheckIn(String id, CheckIn updatedCheckIn) async {
    await _checkInCollection.doc(id).update(updatedCheckIn.toJson());
  }

  /// Delete a check-in record
  Future<void> deleteCheckIn(String id) async {
    await _checkInCollection.doc(id).delete();
  }

  /// Retrieve check-in records for a specific user by name
  Stream<QuerySnapshot<CheckIn>> getUserCheckIns(String name) {
    return _checkInCollection.where('name', isEqualTo: name).snapshots();
  }






  /// Clock out function to update the check-out time
  Future<void> clockOut(String checkInId, DateTime checkoutTime, String checkoutLocation) async {
    await FirebaseFirestore.instance.collection('clockIn').doc(checkInId).update({
      'checkout': Timestamp.fromDate(checkoutTime),
      'checkoutLocation': checkoutLocation, // Store check-out location
    }).catchError((error) {
      print("Error updating checkout: $error");
    });
  }


  Stream<QuerySnapshot<CheckIn>> getCheckOut() {
    return FirebaseFirestore.instance
        .collection('clockIn')
        .withConverter<CheckIn>(
      fromFirestore: (snapshot, _) => CheckIn.fromJson(snapshot.data()!),
      toFirestore: (checkIn, _) => checkIn.toJson(),
    )
        .snapshots();
  }


}