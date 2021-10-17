import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_alert_dialog.dart';
import 'package:matseonim/components/custom_elevated_button.dart';
import 'package:matseonim/components/custom_form_fields.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/join_page1.dart';
import 'package:matseonim/pages/main_page.dart';
import 'package:matseonim/utils/media.dart';
import 'package:matseonim/utils/validator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Container(
        width: getScreenWidth(context),
        height: getScreenHeight(context),
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/logo_flat.png',
                  fit: BoxFit.contain,
                  width: 300,
                ),
                Text(
                  "A급 군생활을 위한 필수 앱, 맞선임", 
                  style: TextStyle(fontSize: 16, color: Colors.white)
                )
              ],
            ),
            Column(
              children: [
                CustomElevatedButton(
                  text: "로그인",
                  elevation: 8,
                  color: Colors.yellow[800],
                  funPageRoute: () {
                    Get.to(_EmailLoginPage());
                  },
                ),
                const SizedBox(height: 30),
                const Text("아직 계정이 없으신가요?",
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  text: "회원가입",
                  textStyle: TextStyle(color: Colors.white),
                  elevation: 8,
                  color: Colors.pink[400],
                  funPageRoute: () async {
                    Get.offAll(JoinPage1());
                  },
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
}

class _EmailLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Container(
        width: getScreenWidth(context),
        height: getScreenHeight(context),
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 20),
              height: 60,
              child: const Text(
                "이메일로 로그인",
                style: TextStyle(
                  fontSize: 32, 
                  color: Colors.white
                ),
              ),
            ),
            Center(child: _EmailLoginForm())
          ],
        ),
      ),
    );
  }
}

class _EmailLoginFormController extends GetxController {
  var formKey = GlobalKey<FormState>();

  var emailTextController = TextEditingController();
  var passwordTextController = TextEditingController();
}

class _EmailLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<_EmailLoginFormController>(
      init: _EmailLoginFormController(),
      builder: (_) {
        return Form(
          key: _.formKey,
          child: Column(
            children: [
              ObscurableFormField(
                shouldObscure: false,
                hintText: "이메일",
                textController: _.emailTextController,
                funValidator: validateEmail(),
              ),
              ObscurableFormField(
                shouldObscure: true,
                hintText: "비밀번호",
                textController: _.passwordTextController,
                funValidator: validatePassword(),
              ),
              CustomElevatedButton(
                text: "로그인",
                elevation: 8,
                color: Colors.yellow[800],
                funPageRoute: () async {
                  if (_.formKey.currentState!.validate()) {
                    MSIUserStatus status = await MSIUser(
                      email: _.emailTextController.text,
                      password: _.passwordTextController.text,
                    ).login();

                    switch (status) {
                      case MSIUserStatus.success:
                        Get.to(MainPage());

                        break;

                      case MSIUserStatus.userNotFound:
                        Get.dialog(
                          const CustomAlertDialog(
                            message: "사용자를 찾을 수 없습니다. 다시 시도해주세요."
                          )
                        );

                        break;

                      case MSIUserStatus.wrongPassword:
                        Get.dialog(
                          const CustomAlertDialog(
                            message: "비밀번호가 틀렸습니다. 다시 시도해주세요."
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
                }
              )
            ]
          )
        );
      },
    );
  }
}
