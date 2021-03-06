import 'package:flutter/material.dart';

import 'package:matseonim/components/custom_profile_widgets.dart';
import 'package:matseonim/components/custom_app_bar.dart';
import 'package:matseonim/components/custom_review_widgets.dart';
import 'package:matseonim/models/user.dart';
import 'package:matseonim/pages/drawer_page.dart';

class ProfilePage extends StatelessWidget {
  final String? uid;

  const ProfilePage({Key? key, this.uid}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerPage(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "프로필 페이지", 
                style: TextStyle(fontSize: 32)
              ),
            ),
            const SizedBox(height: 28),
            LargeProfile(uid: uid),
            const SizedBox(height: 28),
            Text(
              "리뷰", 
              style: TextStyle(fontSize: 16)
             ),
            Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            FutureBuilder(
              future: MSIUser.init(uid: uid!), 
              builder: (BuildContext context, AsyncSnapshot<MSIUser> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator()
                  );
                } else {
                  return ReviewListView(reviewee: snapshot.data!);
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
