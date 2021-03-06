import 'package:cloud_firestore/cloud_firestore.dart';  

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// 사용자가 보낸 문의를 나타내는 클래스.
class MSIInquiry {
  String id, uid;
  String title, description;

  MSIInquiry({
    required this.id,
    required this.uid,
    required this.title,
    required this.description
  });
}

/// 사용자의 문의를 관리하는 클래스.
class MSIInquiries {
  /// 새로운 문의를 생성한다.
  static Future<void> add({
    required String uid,
    required String title,
    required String description
  }) async {
    CollectionReference inquiries = _firestore.collection("inquiries");

    await inquiries.add({
      "uid": uid,
      "title": title,
      "description": description
    });
  }

  /// 의뢰의 고유 ID를 통해 문의 내용을 서버에서 불러온다.
  static Future<MSIInquiry> get({required String id}) async {
    CollectionReference inquiries = _firestore.collection("inquiries");

    DocumentSnapshot document = await inquiries.doc(id).get(); 

    return MSIInquiry(
      id: id,
      uid: document["uid"],
      title: document["title"],
      description: document["description"]
    );
  }

  /// 주어진 고유 ID를 가진 사용자가 생성한 모든 문의를 서버에서 불러온다.
  static Future<List<MSIInquiry>> getOutgoing({required String uid}) async {
    List<MSIInquiry> result = [];

    CollectionReference inquiries = _firestore.collection("inquiries");

    QuerySnapshot query = await inquiries.where("uid", isEqualTo: uid).get();

    for (QueryDocumentSnapshot document in query.docs) {
      result.add(
        MSIInquiry(
          id: document.id,
          uid: document["uid"],
          title: document["title"],
          description: document["description"]
        )
      );
    }

    return result;
  }

  /// 주어진 고유 ID를 가진 문의를 서버에서 삭제한다.
  static Future<void> delete({required String id}) async {
    CollectionReference inquiries = _firestore.collection("inquiries");

    await inquiries.doc(id).delete();
  }

  /// 주어진 고유 ID를 가진 사용자의 모든 문의를 서버에서 삭제한다.
  static Future<void> deleteAll({required String uid}) async {
    CollectionReference inquiries = _firestore.collection("inquiries");

    QuerySnapshot query = await inquiries.where("uid", isEqualTo: uid).get();

    for (QueryDocumentSnapshot document in query.docs) {
      await document.reference.delete();
    }
  }
}