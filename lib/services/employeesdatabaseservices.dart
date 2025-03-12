import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/employeesdata.dart';

const String usercollection = 'EmployeeData';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Employeesdata> _usersCollection;

  DatabaseService() {
    _usersCollection =
        _firestore.collection(usercollection).withConverter<Employeesdata>(
          fromFirestore: (snapshot, _) =>
              Employeesdata.fromJson(snapshot.data()!),
          toFirestore: (employeesdata, _) => employeesdata.toJson(),
        );
  }

  Stream<List<Employeesdata>> getEmployees() {
    return _usersCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addEmployeesData(Employeesdata employee) async {
    try {
      await _usersCollection.add(employee);
      print("Employee added successfully!");
    } catch (e) {
      print("Error adding employee: $e");
    }
  }
}