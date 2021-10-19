import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:matseonim/models/request.dart';
import 'package:matseonim/models/review.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// 사용자 계정 관련 작업의 결과를 나타내는 열거형.
enum MSIUserStatus {
  success,
  alreadyLoggedIn,
  emailAlreadyInUse,
  invalidEmail,
  invalidUser,
  requiresRecentLogin,
  unknownError,
  userNotFound,
  weakPassword,
  wrongPassword
}

/// 사용자가 받은 알림의 종류를 나타내는 열거형.
enum MSINotificationType {
  acceptedRequest,
  newChatMessages,
  newReview
}

/// 사용자가 받은 알림을 나타내는 클래스.
class MSINotification {
  MSINotificationType type;

  String id, uid, payload;

  int createdAt;

  MSINotification({
    required this.id,
    required this.uid,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  Future<String> getMessage() async {
    MSIUser sender = await MSIUser.init(uid: uid);

    switch (type) {
      case MSINotificationType.acceptedRequest:
        return "${sender.name}님이 맞선임 요청을 수락하였습니다.";

      case MSINotificationType.newChatMessages:
        return "${sender.name}님이 새로운 메시지를 보냈습니다.";

      case MSINotificationType.newReview:
        return "${sender.name}님이 리뷰를 남겼습니다.";
    }
  }
}

/// 사용자의 계정 정보를 나타내는 클래스.
class MSIUser {
  final CollectionReference _users = _firestore.collection("users");
  
  String? uid, name, email, password, phoneNumber;
  String? profession, interest, resume, avatarUrl, baseName;

  List<dynamic>? msiList, mhiList;

  double? rating;

  MSIUser({
    this.uid,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.profession,
    this.interest,
    this.resume,
    this.avatarUrl,
    this.baseName,
    this.msiList,
    this.mhiList,
    this.rating
  });

  /// 사용자 정보를 초기화한다.
  static Future<MSIUser> init({String? uid}) async {
    if (uid == null && _auth.currentUser == null) {
      throw Exception("고유 ID가 null 값인 사용자는 초기화할 수 없습니다.");
    }

    MSIUser result = MSIUser(uid: uid ?? _auth.currentUser!.uid);

    await result._init();

    return result;
  }

  /// 사용자 계정에 로그인한다.
  Future<MSIUserStatus> login() async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email!, 
        password: password!
      );

      uid = credential.user!.uid;

      await _init();
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        return MSIUserStatus.invalidEmail;
      } else if (e.code == "user-not-found") {
        return MSIUserStatus.userNotFound;
      } else if (e.code == "wrong-password") {
        return MSIUserStatus.wrongPassword;
      }
    } catch (e) {
      return MSIUserStatus.unknownError;
    }

    return MSIUserStatus.success;
  }

  /// 사용자 계정에서 로그아웃한다.
  Future<MSIUserStatus> logout() async {
    if (_auth.currentUser == null) {
      return MSIUserStatus.invalidUser;
    }

    await _auth.signOut();

    return MSIUserStatus.success;
  }

  /// 이메일과 비밀번호로 회원가입을 진행한다.
  Future<MSIUserStatus> signUp() async {
    try {
      if (uid != null) {
        return MSIUserStatus.alreadyLoggedIn;
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email!, 
        password: password!
      );

      uid = credential.user!.uid;

      await _users.doc(uid!).set({
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "profession": profession,
        "interest": interest,
        "resume": "(없음)",
        "avatarUrl": "",
        "baseName": baseName,
        "msiList": [],
        "mhiList": [],
        "rating": 0.0
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return MSIUserStatus.emailAlreadyInUse;
      } else if (e.code == "invalid-email") {
        return MSIUserStatus.invalidEmail;
      } else if (e.code == "weak-password") {
        return MSIUserStatus.weakPassword;
      }
    } catch (e) {
      return MSIUserStatus.unknownError;
    }

    return MSIUserStatus.success;
  }

  /// 사용자 계정의 비밀번호를 변경한다.
  Future<MSIUserStatus> changePassword({
    required String oldPassword, 
    required String newPassword
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email ?? "", 
        password: oldPassword
      );

      await credential.user!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        return MSIUserStatus.invalidEmail;
      } else if (e.code == "requires-recent-login") {    
        return MSIUserStatus.requiresRecentLogin;
      } else if (e.code == "user-not-found") {
        return MSIUserStatus.userNotFound;
      } else if (e.code == "weak-password") {
        return MSIUserStatus.weakPassword;
      } else if (e.code == "wrong-password") {
        return MSIUserStatus.wrongPassword;
      }
    } catch (e) {
      return MSIUserStatus.unknownError;
    }

    return MSIUserStatus.success;
  }

  /// 다른 사용자의 의뢰 요청을 수락한다.
  Future<MSIUserStatus> acceptRequest({required MSIRequest request}) async {
    if (uid == null || uid == request.uid) {
      return MSIUserStatus.invalidUser;
    }

    if (mhiList != null && !mhiList!.contains(request.uid)) {
      mhiList!.add(request.uid);
      await update();
    }

    MSIUser mhi = await MSIUser.init(uid: request.uid);

    if (mhi.msiList != null && !mhi.msiList!.contains(uid)) {
      mhi.msiList!.add(uid);
      await mhi.update();
    }

    await MSIRequests.delete(id: request.id);

    return MSIUserStatus.success;
  }

  /// 사용자에게 새로운 알림을 보낸다.
  Future<void> sendNotification({
    required MSINotificationType type,
    required MSIUser sender,
    required String payload
  }) async {
    await _users.doc(uid!)
      .collection("notifications")
      .add({
        "uid": sender.uid,
        "type": type.index,
        "payload": payload,
        "createdAt": Timestamp.now().millisecondsSinceEpoch
      });
  }

  /// 사용자가 받은 모든 알림을 반환한다.
  Future<List<MSINotification>> getNotifications() async {
    List<MSINotification> result = [];

    QuerySnapshot query = await _users.doc(uid!)
      .collection("notifications")
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      result.add(
        MSINotification(
          id: document.id,
          uid: document["uid"],
          type: MSINotificationType.values[document["type"]],
          payload: document["payload"],
          createdAt: document["createdAt"]
        )
      );
    }

    return result;
  }

  /// 사용자가 받은 알림을 삭제한다.
  Future<void> deleteNotification({
    required String id
  }) async {
    await _users.doc(uid!)
      .collection("notifications")
      .doc(id)
      .delete();
  }

  /// 사용자가 받은 모든 알림을 삭제한다.
  Future<void> deleteNotifications() async {
    QuerySnapshot query = await _users.doc(uid!)
      .collection("notifications")
      .get();

    for (QueryDocumentSnapshot document in query.docs) {
      await document.reference.delete();
    }
  }

  /// 사용자 정보를 서버에서 다시 불러온다.
  Future<void> reload() async {
    await _init();
  }

  /// 서버에 저장된 사용자 정보를 업데이트한다.
  Future<MSIUserStatus> update() async {
    if (uid == null) {
      return MSIUserStatus.invalidUser;
    } 

    await _users.doc(uid!).update({
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "profession": profession,
      "interest": interest,
      "resume": resume,
      "avatarUrl": avatarUrl,
      "baseName": baseName,
      "msiList": msiList ?? [],
      "mhiList": mhiList ?? [],
      "rating": rating
    });

    return MSIUserStatus.success;
  }

  /// 사용자 계정을 삭제한다.
  Future<MSIUserStatus> delete() async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email!, 
        password: password!
      );

      await credential.user!.delete();
      await _users.doc(credential.user!.uid).delete();
    } on FirebaseAuthException catch (e) {
       if (e.code == "requires-recent-login") {    
        return MSIUserStatus.requiresRecentLogin;
      }
    } catch (e) {
      return MSIUserStatus.unknownError;
    }

    return MSIUserStatus.success;
  }

  /// 사용자 정보를 서버에서 불러온다.
  Future<void> _init() async {
    DocumentSnapshot snapshot = await _users.doc(uid!).get();

    if (snapshot.exists) {
      name = snapshot["name"];
      email = snapshot["email"];
      phoneNumber = snapshot["phoneNumber"];
      profession = snapshot["profession"];
      interest = snapshot["interest"];
      resume = snapshot["resume"];
      avatarUrl = snapshot["avatarUrl"];
      baseName = snapshot["baseName"];
      msiList = snapshot["msiList"] ?? [];
      mhiList = snapshot["mhiList"] ?? [];
      
      rating = await MSIReviews.getAverageRatingFor(
        reviewee: this
      );
    }
  }
}