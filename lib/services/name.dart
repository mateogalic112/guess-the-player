

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseQuery{
  Future<QuerySnapshot> getNameQuery(String id) async{
    QuerySnapshot snapshot = await Firestore.instance.collection('Users').where(
      'userId', isEqualTo: id).getDocuments();
    return snapshot;
  }

}