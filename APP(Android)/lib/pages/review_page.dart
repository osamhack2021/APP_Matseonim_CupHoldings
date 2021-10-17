import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_alert_dialog.dart';
import 'package:matseonim/components/custom_app_bar.dart';
import 'package:matseonim/components/custom_elevated_button.dart';
import 'package:matseonim/components/custom_form_fields.dart';
import 'package:matseonim/components/custom_profile_widgets.dart';
import 'package:matseonim/components/custom_rating_bar.dart';
import 'package:matseonim/models/review.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/drawer_page.dart';
import 'package:matseonim/pages/profile_page.dart';
import 'package:matseonim/utils/validator.dart';

class ReviewPage extends StatelessWidget {
  final String revieweeId;

  const ReviewPage({
    Key? key, 
    required this.revieweeId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true),
      drawer: DrawerPage(),
      body: FutureBuilder(
        future: Future.wait([
          MSIUser.init(),
          MSIUser.init(uid: revieweeId)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<MSIUser>> snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              child: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator()
              )
            );
          } else {
            final List<MSIUser> users = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CreateReviewForm(
                reviewer: users[0],
                reviewee: users[1]
              )
            );
          }
        },
      ),
    );
  }
}

class _CreateReviewFormController extends GetxController {
  var formKey = GlobalKey<FormState>();

  var valueTextController = TextEditingController();
}

class _CreateReviewForm extends StatelessWidget {
  final MSIUser reviewer, reviewee;

  const _CreateReviewForm({
    Key? key,
    required this.reviewer,
    required this.reviewee
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double newRating = 3.0;

    return GetBuilder<_CreateReviewFormController>(
      init: _CreateReviewFormController(),
      builder: (_) {
        return Form(
          key: _.formKey,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "리뷰 쓰기",
                  style: TextStyle(fontSize: 32)
                ),
              ),
              ReviewProfile(uid: reviewee.uid!),
              SizedBox(height: 20),
              Center(
                child: CustomRatingBar(
                  initialValue: 3.0,
                  onUpdate: (double rating) {
                    newRating = rating;
                  }
                )
              ),
              SizedBox(height: 15),
              MultilineFormField(
                textController: _.valueTextController,
                funValidator: validateText()
              ),
              SizedBox(height: 20),
              CustomElevatedButton(
                text: "작성 완료",
                textStyle: const TextStyle(
                  fontSize: 16, 
                  color: Colors.white
                ),
                color: Theme.of(context).primaryColor,
                funPageRoute: () async {
                  if (_.formKey.currentState!.validate()) {
                    await MSIReviews.add(
                      reviewerId: reviewer.uid!, 
                      revieweeId: reviewee.uid!, 
                      rating: newRating, 
                      value: _.valueTextController.text
                    );

                    await reviewee.sendNotification(
                      type: MSINotificationType.newReview, 
                      sender: reviewer, 
                      payload: ""
                    );

                    await Get.dialog(
                      const CustomAlertDialog(
                        message: "리뷰가 작성되었습니다."
                      )
                    );

                    Get.to(ProfilePage(uid: reviewee.uid));
                  }
                }
              )
            ],
          )
        );
      },
    );
  }
}
