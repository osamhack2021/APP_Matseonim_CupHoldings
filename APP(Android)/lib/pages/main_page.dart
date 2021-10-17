import 'package:flutter/material.dart';

import 'package:matseonim/components/custom_app_bar.dart';
import 'package:matseonim/components/custom_slider_widgets.dart';
import 'package:matseonim/components/custom_profile_widgets.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/drawer_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerPage(),
      body: FutureBuilder(
        future: MSIUser.init(),
        builder: (BuildContext context, AsyncSnapshot<MSIUser> snapshot) {
          if (!snapshot.hasData) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator()));
          } else {
            final MSIUser user = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "새로운 사연",
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomCarouselSlider(field: user.profession!, user: user),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "내 맞선임",
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SmallProfileListView(uidList: user.msiList ?? []),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "내 맞후임",
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SmallProfileListView(uidList: user.mhiList ?? [])
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "실시간 리뷰",
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                      SizedBox(height: 15),
                      CustomReviewSlider(),
                      SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      )
    );
  }
}
