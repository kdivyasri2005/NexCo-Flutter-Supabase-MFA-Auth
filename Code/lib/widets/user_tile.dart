import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexco/models/user_model.dart';
import 'package:nexco/routes/route_names.dart';
import 'package:nexco/utils/helper.dart';
import 'package:nexco/widets/circle_image.dart';
class UserTile extends StatelessWidget {
  final UserModel user;
  const UserTile({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: CircleImage(url: user.metadata?.image),
      ),
      title: Text(user.metadata!.name!),
      titleAlignment: ListTileTitleAlignment.top,
      trailing: OutlinedButton(
        onPressed: () {
          Get.toNamed(RouteNames.showProfile, arguments: user.id!);
        },
        child: const Text("View profile"),
      ),
      subtitle: Text(formateDateFromNow(user.createdAt!)),
    );
  }
}
