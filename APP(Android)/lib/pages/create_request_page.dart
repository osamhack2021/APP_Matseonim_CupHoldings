import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_alert_dialog.dart';
import 'package:matseonim/components/custom_app_bar.dart';
import 'package:matseonim/components/custom_elevated_button.dart';
import 'package:matseonim/components/custom_form_fields.dart';
import 'package:matseonim/models/request.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/drawer_page.dart';
import 'package:matseonim/pages/main_page.dart';
import 'package:matseonim/utils/validator.dart';

class CreateRequestPage extends StatelessWidget {
  const CreateRequestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true),
      drawer: DrawerPage(),
      body: FutureBuilder(
        future: MSIUser.init(),
        builder: (BuildContext context, AsyncSnapshot<MSIUser> snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              child: Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator()
              )
            );
          } else {
            final MSIUser user = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CreateRequestForm(user: user)
            );
          }
        },
      ),
    );
  }
}

class _CreateRequestFormController extends GetxController {
  var formKey = GlobalKey<FormState>();

  var titleTextController = TextEditingController();
  var descriptionTextController = TextEditingController();
  var fieldTextController = TextEditingController();
}

class _CreateRequestForm extends StatelessWidget {
  final MSIUser user;

  const _CreateRequestForm({
    Key? key,
    required this.user
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_CreateRequestFormController>(
      init: _CreateRequestFormController(),
      builder: (_) {
        return Form(
          key: _.formKey,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "의뢰 요청", 
                  style: TextStyle(fontSize: 32)
                ),
              ),
              ObscurableFormField(
                shouldObscure: false,
                hintText: "제목",
                funValidator: validateText(),
                textController: _.titleTextController,
              ),
              SizedBox(height: 20),
              MultilineFormField(
                textController: _.descriptionTextController,
                funValidator: validateText()
              ),
              SizedBox(height: 20),
              AutocompleteForm(
                hintText: "요청 분야를 입력해주세요",
                textController: _.fieldTextController,
              ),
              SizedBox(height: 20),
              CustomElevatedButton(
                text: "저장",
                textStyle: const TextStyle(
                  fontSize: 16, 
                  color: Colors.white
                ),
                color: Theme.of(context).primaryColor,
                funPageRoute: () async {
                  if (_.formKey.currentState!.validate()) {
                    await MSIRequests.add(
                      uid: '${user.uid}',
                      field: _.fieldTextController.text,
                      title: _.titleTextController.text,
                      description: _.descriptionTextController.text,
                    );

                    await Get.dialog(
                      const CustomAlertDialog(
                        message: "의뢰 요청이 완료되었습니다."
                      )
                    );

                    Get.to(MainPage());
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
