import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_elevated_button.dart';
import 'package:matseonim/components/custom_form_fields.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/join_page2.dart';
import 'package:matseonim/utils/media.dart';
import 'package:matseonim/utils/validator.dart';

class JoinPage1 extends StatelessWidget {
  const JoinPage1({Key? key}) : super(key: key);

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
                "회원가입 (1/2)",
                style: TextStyle(
                  fontSize: 32, 
                  color: Colors.white
                ),
              ),
            ),
            _JoinForm1()
          ]
        )
      )
    );
  }
}

class _JoinForm1Controller extends GetxController {
  var formKey = GlobalKey<FormState>();

  var nameTextController = TextEditingController();
  var phoneNumberTextController = TextEditingController();
  var emailTextController = TextEditingController();
  var passwordTextController = TextEditingController();
  var confirmPasswordTextController = TextEditingController();
}

class _JoinForm1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<_JoinForm1Controller>(
      init: _JoinForm1Controller(),
      builder: (_) {
        return Form(
          key: _.formKey,
          child: Column(
            children: [
              ObscurableFormField(
                shouldObscure: false,
                hintText: "성명",
                funValidator: validateName(),
                textController: _.nameTextController,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ObscurableFormField(
                  shouldObscure: false,
                  hintText: "휴대폰 번호 (010-XXXX-XXXX)",
                  funValidator: validatePhoneNumber(),
                  textController: _.phoneNumberTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ObscurableFormField(
                  shouldObscure: false,
                  hintText: "이메일",
                  funValidator: validateEmail(),
                  textController: _.emailTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ObscurableFormField(
                  shouldObscure: true,
                  hintText: "비밀번호",
                  funValidator: validatePassword(saveValue: true),
                  textController: _.passwordTextController
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ObscurableFormField(
                  shouldObscure: true,
                  hintText: "비밀번호 확인",
                  funValidator: validateConfirmPassword(),
                  textController: _.confirmPasswordTextController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: CustomElevatedButton(
                  text: "다음",
                  funPageRoute: () {
                    if (_.formKey.currentState!.validate()) {
                      Get.to(
                        JoinPage2(),
                        arguments: MSIUser(
                          name: _.nameTextController.text,
                          phoneNumber: _.phoneNumberTextController.text,
                          email: _.emailTextController.text,
                          password: _.passwordTextController.text
                        )
                      );
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
