import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_alert_dialog.dart';
import 'package:matseonim/components/custom_elevated_button.dart';
import 'package:matseonim/components/custom_form_fields.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/login_page.dart';
import 'package:matseonim/utils/media.dart';

class JoinPage2 extends StatelessWidget {
  const JoinPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Container(
        width: getScreenWidth(context),
        height: getScreenHeight(context),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              height: 220,
              alignment: Alignment.center,
              child: const Text(
                "회원가입 (2/2)",
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            _JoinForm2()
          ],
        ),
      ),
    );
  }
}

class _JoinForm2Controller extends GetxController {
  var formKey = GlobalKey<FormState>();

  var professionTextController = TextEditingController();
  var interestTextController = TextEditingController();
  var baseTextController = TextEditingController();
}

class _JoinForm2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<_JoinForm2Controller>(
      init: _JoinForm2Controller(),
      builder: (_) {
        return Form(
          key: _.formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AutocompleteForm(
                  hintText: "소속 비행단을 입력해주세요",
                  formFlag: AutocompleteFormFlag.baseNames,
                  textController: _.baseTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AutocompleteForm(
                  hintText: "전문 분야를 입력해 주세요",
                  textController: _.professionTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AutocompleteForm(
                  hintText: "관심 분야를 입력해 주세요",
                  textController: _.interestTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: CustomElevatedButton(
                  text: "회원가입",
                  textStyle: TextStyle(color: Colors.white),
                  color: Colors.pink[400],
                  funPageRoute: () async {
                    if (_.formKey.currentState!.validate()) {
                      final MSIUser user = Get.arguments;

                      user.profession = _.professionTextController.text;
                      user.interest = _.interestTextController.text;
                      user.baseName = _.baseTextController.text;

                      switch (await user.signUp()) {
                        case MSIUserStatus.success:
                          Get.offAll(LoginPage());

                          Get.dialog(
                            const CustomAlertDialog(
                              message: "회원가입이 완료되었습니다."
                            )
                          );

                          break;

                        case MSIUserStatus.emailAlreadyInUse:
                          Get.dialog(
                            const CustomAlertDialog(
                              message: "이미 사용 중인 이메일 주소입니다."
                            )
                          );

                          break;

                        default:
                          Get.dialog(
                            const CustomAlertDialog(
                              message: "오류가 발생하였습니다. 다시 시도해주세요."
                            )
                          );

                          break;
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
