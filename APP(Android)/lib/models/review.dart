import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:matseonim/models/user.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// 사용자의 평가를 나타내는 클래스.
class MSIReview {
  String id, reviewerId, revieweeId, value;

  double rating;

  MSIReview({
    required this.id,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.value
  });
}

/// 사용자의 평가를 관리하는 클래스.
class MSIReviews {
  /// 새로운 평가를 생성한다.
  static Future<void> add({
    required String reviewerId,
    required String revieweeId,
    required double rating,
    required String value
  }) async {
    CollectionReference requests = _firestore.collection("reviews");

    await requests.add({
      "reviewerId": reviewerId,
      "revieweeId": revieweeId,
      "rating": rating,
      "value": value
    });
  }

  /// 주어진 사용자를 대상으로 한 모든 평가의 평균 평점을 계산한다.
  static Future<double> getAverageRatingFor({required MSIUser reviewee}) async {
    List<MSIReview> reviews = await getFor(reviewee: reviewee);

    double result = 0.0;

    if (reviews.isEmpty) {
      return result;
    }

    for (var review in reviews) {
      result += review.rating;
    }

    result /= reviews.length;

    return result;
  }

  /// 주어진 사용자를 대상으로 작성된 모든 평가를 서버에서 불러온다.
  static Future<List<MSIReview>> getFor({required MSIUser reviewee}) async {
    List<MSIReview> result = [];

    if (reviewee.uid == null) {
      return result;
    }

    QuerySnapshot query = await _firestore.collection("reviews")
      .where("revieweeId", isEqualTo: reviewee.uid)
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      result.add(
        MSIReview(
          id: document.id,
          reviewerId: document["reviewerId"],
          revieweeId: document["revieweeId"],
          rating: (document["rating"] as num).toDouble(),
          value: document["value"]
        )
      );
    }

    return result;
  }

  static Future<List<MSIReview>> getAll() async {
    List<MSIReview> result = [];

    QuerySnapshot query = await _firestore.collection("reviews").limit(7)
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      result.add(
        MSIReview(
          id: document.id,
          reviewerId: document["reviewerId"],
          revieweeId: document["revieweeId"],
          rating: (document["rating"] as num).toDouble(),
          value: document["value"]
        )
      );
    }

    return result;
  }

  /// 주어진 사용자를 대상으로 작성된 모든 평가를 서버에서 불러온다.
  static Future<List<MSIReview>> getFrom({required MSIUser reviewer}) async {
    List<MSIReview> result = [];

    QuerySnapshot query = await _firestore.collection("reviews")
      .where("reviewerId", isEqualTo: reviewer.uid)
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      result.add(
        MSIReview(
          id: document.id,
          reviewerId: document["reviewerId"],
          revieweeId: document["revieweeId"],
          rating: (document["rating"] as num).toDouble(),
          value: document["value"]
        )
      );
    }

    return result;
  }

  /// 주어진 고유 ID를 가진 평가를 서버에서 삭제한다.
  static Future<void> delete({required String id}) async {
    CollectionReference requests = _firestore.collection("reviews");

    await requests.doc(id).delete();
  }

  /// 주어진 사용자가 생성한 모든 평가를 서버에서 삭제한다.
  static Future<void> deleteAll({required MSIUser user}) async {
    CollectionReference requests = _firestore.collection("reviews");

    QuerySnapshot query = await requests
      .where("reviewerId", isEqualTo: user.uid)
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      await document.reference.delete();
    }
  }
}