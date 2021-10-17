import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:matseonim/components/custom_alert_dialog.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/notification_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const CustomAppBar({
    Key? key, 
    this.showBackButton = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        'assets/images/logo_flat.png', 
        fit: BoxFit.contain,
        width: 140
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[900],
      elevation: 1.0,
      leading: Builder(
        builder: (BuildContext context) {
          if (!showBackButton) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              }
            );
          } else {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Get.back();
              }
            );
          }
        },
      ),
      actions: [
        FutureBuilder(
          future: _getUserNotifications(), 
          builder: (BuildContext context, AsyncSnapshot<List<MSINotification>> snapshot) { 
            if (!snapshot.hasData) {
              return IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                iconSize: 30,
                onPressed: () { 
                  Get.dialog(
                    const CustomAlertDialog(
                      message: "잠시만 기다려주세요."
                    )
                  );
                },
              );
            } else {
              final List<MSINotification> notifications = snapshot.data!;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                    onPressed: () { 
                      Get.to(NotificationPage());
                    },
                  ),
                  (notifications.isNotEmpty) 
                    ? Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${notifications.length}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center
                        )
                      )
                    )
                    : Container()
                ]
              );
            }
          }
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 현재 사용자가 받은 모든 알림을 반환한다.
Future<List<MSINotification>> _getUserNotifications() async {
  MSIUser user = await MSIUser.init();

  return user.getNotifications();
}