import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:nexco/controllers/setting_controller.dart';
import 'package:nexco/utils/helper.dart';

class Setting extends StatelessWidget {
  Setting({super.key});

  final SettingController controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              onTap: () {
                confirmBox(
                  "Are you sure",
                  "this action logout u from app.",
                  controller.logout,
                );
              },
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
