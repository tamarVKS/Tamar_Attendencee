import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/signupdetails.dart';

const String userCollection = 'Employees';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<SignupDetails> _usersCollection;

  DatabaseService() {
    _usersCollection = _firestore
        .collection(userCollection)
        .withConverter<SignupDetails>(
      fromFirestore: (snapshot, _) =>
          SignupDetails.fromJson(snapshot.data()!),
      toFirestore: (signup, _) => signup.toJson(),
    );
  }

  // ✅ Stream to get employees
  Stream<QuerySnapshot<SignupDetails>> getEmployees() {
    return _usersCollection.snapshots();
  }

  // ✅ Add Employee
  Future<void> addData(SignupDetails newProfile) async {
    try {
      await _usersCollection.add(newProfile);
      print("Employee added successfully!");
    } catch (e) {
      print("Error adding employee: $e");
    }
  }

  // ✅ Update Employee Data by Document ID
  Future<void> updateEmployee(String docId, SignupDetails updatedProfile) async {
    try {
      await _usersCollection.doc(docId).set(updatedProfile);
      print("Employee updated successfully!");
    } catch (e) {
      print("Error updating employee: $e");
    }
  }
}
