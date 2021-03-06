import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:matseonim/models/user.dart';  

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// 사용자가 보낸 의뢰 요청을 나타내는 클래스.
class MSIRequest {
  String id, uid, field;
  String title, description;

  MSIRequest({
    required this.id,
    required this.uid,
    required this.field,
    required this.title,
    required this.description
  });
}

/// 사용자의 의뢰 요청을 관리하는 클래스.
class MSIRequests {
  /// 새로운 의뢰를 생성한다.
  static Future<void> add({
    required String uid,
    required String field,
    required String title,
    required String description
  }) async {
    CollectionReference requests = _firestore.collection("requests");

    await requests.add({
      "uid": uid,
      "field": field,
      "title": title,
      "description": description
    });
  }

  /// 주어진 사용자의 전문 분야와 연관된 모든 의뢰를 서버에서 불러온다.
  static Future<List<MSIRequest>> getIncoming({required MSIUser user}) async {
    List<MSIRequest> result = [];

    QuerySnapshot query = await _firestore.collection("requests")
      .where("field", isEqualTo: user.profession)
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      if (user.uid == document["uid"] || user.mhiList!.contains(document["uid"])) {
        continue;
      }

      result.add(
        MSIRequest(
          id: document.id,
          uid: document["uid"],
          field: document["field"],
          title: document["title"],
          description: document["description"]
        )
      );
    }

    return result;
  }

  /// 주어진 고유 ID를 가진 사용자가 생성한 모든 의뢰를 서버에서 불러온다.
  static Future<List<MSIRequest>> getOutgoing({required String uid}) async {
    List<MSIRequest> result = [];

    CollectionReference requests = _firestore.collection("requests");

    QuerySnapshot query = await requests.where("uid", isEqualTo: uid).get();

    for (QueryDocumentSnapshot document in query.docs) {
      result.add(
        MSIRequest(
          id: document.id,
          uid: document["uid"],
          field: document["field"],
          title: document["title"],
          description: document["description"]
        )
      );
    }

    return result;
  }

  /// 주어진 고유 ID를 가진 의뢰를 서버에서 삭제한다.
  static Future<void> delete({required String id}) async {
    CollectionReference requests = _firestore.collection("requests");

    await requests.doc(id).delete();
  }

  /// 주어진 고유 ID를 가진 사용자의 모든 의뢰를 서버에서 삭제한다.
  static Future<void> deleteAll({required String uid}) async {
    CollectionReference requests = _firestore.collection("requests");

    QuerySnapshot query = await requests.where("uid", isEqualTo: uid).get();

    for (QueryDocumentSnapshot document in query.docs) {
      await document.reference.delete();
    }
  }
}