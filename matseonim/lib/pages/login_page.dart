import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_alert_dialog.dart';
import 'package:matseonim/components/custom_elevated_button.dart';
import 'package:matseonim/components/custom_form_fields.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/join_page1.dart';
import 'package:matseonim/pages/main_page.dart';
import 'package:matseonim/utils/validator.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return _ErrorPage();
        } else {
          return (snapshot.connectionState != ConnectionState.done)
            ? _LoadingPage()
            : _MainLoginPage();
        }
      }
    );
  }
}

class _ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[900],
        body: const CustomAlertDialog(message: "오류가 발생하였습니다. 다시 시도해주세요."));
  }
}

class _LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[900],
        body: Center(
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(
                        color: Theme.of(context).backgroundColor)))));
  }
}

class _MainLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Image.asset(
                    'images/logo_flat.png',
                    fit: BoxFit.contain,
                    width: 300,
                  ),
                  Text("A급 군생활을 위한 필수 앱, 맞선임", style: TextStyle(fontSize: 16, color: Colors.white),)
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
                      Get.to(JoinPage1());
                    },
                  ),
                ],
              )
            ]
          ),
        ),
      )
    );
  }
}

class _EmailLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              height: 200,
              child: const Text(
                "이메일로 로그인",
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            _EmailLoginForm(),
          ],
        ),
      ),
    );
  }
}

class _EmailLoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          ObscurableFormField(
              shouldObscure: false,
              hintText: "이메일",
              funValidator: validateEmail(),
              textController: _emailTextController),
          ObscurableFormField(
            shouldObscure: true,
            hintText: "비밀번호",
            funValidator: validatePassword(),
            textController: _passwordTextController,
          ),
          CustomElevatedButton(
              text: "로그인",
              funPageRoute: () async {
                if (_formKey.currentState!.validate()) {
                  MSIUserStatus status = await MSIUser(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .login();

                  if (status == MSIUserStatus.success) {
                    Get.to(MainPage());
                  } else if (status == MSIUserStatus.userNotFound) {
                    Get.dialog(const CustomAlertDialog(
                        message: "사용자를 찾을 수 없습니다. 다시 시도해주세요."));
                  } else if (status == MSIUserStatus.wrongPassword) {
                    Get.dialog(const CustomAlertDialog(
                        message: "비밀번호가 틀렸습니다. 다시 시도해주세요."));
                  } else {
                    Get.dialog(const CustomAlertDialog(
                        message: "오류가 발생하였습니다. 다시 시도해주세요."));
                  }
                }
              })
        ]));
  }
}
