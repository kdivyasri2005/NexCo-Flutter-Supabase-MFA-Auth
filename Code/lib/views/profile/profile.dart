import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexco/controllers/profile_controller.dart';
import 'package:nexco/routes/route_names.dart';
import 'package:nexco/services/supabase_service.dart';
import 'package:nexco/utils/sliver_appbar_delete.dart';
import 'package:nexco/utils/styles/button_styles.dart';
import 'package:nexco/widets/circle_image.dart';
import 'package:nexco/widets/comment_card.dart';
import 'package:nexco/widets/loading.dart';
import 'package:nexco/widets/post_card.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    if (supabaseService.currentUser.value?.id != null) {
      controller.fetchPosts(supabaseService.currentUser.value!.id);
      controller.fetchComments(supabaseService.currentUser.value!.id);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.language),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () => Get.toNamed(RouteNames.setting),
              icon: const Icon(Icons.sort))
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 160,
                collapsedHeight: 160,
                automaticallyImplyLeading: false,
                flexibleSpace: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                    () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      supabaseService.currentUser.value
                                          ?.userMetadata?["name"] ??
                                          "Tushar",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.width * 0.60,
                                      child: Text(supabaseService
                                          .currentUser
                                          .value
                                          ?.userMetadata?["description"] ??
                                          "threads clone coding with Tushar"),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                    () => CircleImage(
                                  url: supabaseService.currentUser.value
                                      ?.userMetadata?["image"],
                                  radius: 40,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Get.toNamed(RouteNames.editProfile);
                                  },
                                  style: customOutlineStyle(),
                                  child: const Text("Edit profile"),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: customOutlineStyle(),
                                  child: const Text("Share profile"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SliverPersistentHeader(
                floating: true,
                pinned: true,
                delegate: SliverAppBarDelegate(
                  const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Threads'),
                      Tab(text: 'Replies'),
                    ],
                  ),
                ),
              )
            ];
          },
          body: TabBarView(
            children: [
              Obx(
                    () => SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      if (controller.postLoading.value)
                        const Loading()
                      else if (controller.posts.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.posts.length,
                          itemBuilder: (context, index) => PostCard(
                            post: controller.posts[index],
                            isAuthPost: true,
                            callback: controller.deleteThread,
                          ),
                        )
                      else
                        const Center(
                          child: Text("No Post found"),
                        )
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Obx(
                      () => controller.replyLoading.value
                      ? const Loading()
                      : Column(
                    children: [
                      const SizedBox(height: 10),
                      if (controller.comments.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.comments.length,
                          itemBuilder: (context, index) => CommentCard(
                            comment: controller.comments[index]!,
                            isAuthCard: true,
                            callback: controller.deleteReply,
                          ),
                        )
                      else
                        const Center(
                          child: Text("No reply found"),
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
