import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/profiledetails.dart';

const String userCollection = 'ProfileInformation';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<ProfileDetails> _usersCollection;

  DatabaseService() {
    _usersCollection = _firestore.collection(userCollection).withConverter<ProfileDetails>(
      fromFirestore: (snapshot, _) => ProfileDetails.fromJson(snapshot.data()!),
      toFirestore: (employee, _) => employee.toJson(),
    );
  }

  Stream<List<ProfileDetails>> getEmployees() {
    return _usersCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addEmployee(ProfileDetails employee) async {
    await _usersCollection.add(employee);
  }

  Future<ProfileDetails?> getEmployeeByEmail(String email) async {
    var querySnapshot = await _usersCollection.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }
}
