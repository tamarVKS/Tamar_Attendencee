import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tamar_attendence/models/profiledetails.dart';

const String personInformation = 'ProfileInformation';
 class DatabaseService{
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   late final CollectionReference<ProfileDetails> _collectionReference;

   DatabaseService(){
     _collectionReference = _firestore.collection(personInformation).withConverter<ProfileDetails>(
       fromFirestore: (snapshot, _) => ProfileDetails.fromJson(snapshot.data()!),
       toFirestore: (ProfileDetails, _) => ProfileDetails.toJson(),
     );

   }

   Stream<QuerySnapshot<ProfileDetails>> getName(){
     return _collectionReference.snapshots();
   }

   Future<void> addData(ProfileDetails profileDetails) async{
     await _collectionReference.add(profileDetails);
   }



 }