import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/signupdetails.dart';

const String userCollection = 'Employees';

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;

  DatabaseService(){
    _usersCollection = _firestore.collection(_usersCollection as String).withConverter<SignupDetails>(fromFirestore: (snapshot, _) => SignupDetails.fromJson(snapshot.data()!),
        toFirestore:(todo, _) => todo.toJson());
  }


  Stream<QuerySnapshot> getemployee(){
    return _usersCollection.snapshots();
  }


  Future<void> addEmployee(SignupDetails employee) async {
    try {
      await _usersCollection.add(employee);
      print("Employee added successfully!");
    } catch (e) {
      print("Error adding employee: $e");
    }
  }


}
