import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamar_attendence/models/basicInfo.dart';

const String basicdetails = "BasicInfo";

class BasicInfoDatabaseService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<BasicInfo> _usersCollection;


  BasicInfoDatabaseService() {
    _usersCollection = _firestore.collection(basicdetails).withConverter<BasicInfo>(
      fromFirestore: (snapshot, _) => BasicInfo.fromJson(snapshot.data()!),
      toFirestore: (basicInfo, _) => basicInfo.toJson(),
    );

    Stream<QuerySnapshot<BasicInfo>> getBasicInfo(){
      return _usersCollection.snapshots();
    }



  }
}