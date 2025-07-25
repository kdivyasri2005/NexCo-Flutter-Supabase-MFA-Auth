import 'package:get/get.dart';
import 'package:nexco/models/post_model.dart';
import 'package:nexco/models/user_model.dart';
import 'package:nexco/services/supabase_service.dart';
import 'package:nexco/utils/helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  RxList<PostModel> posts = RxList<PostModel>();
  var loading = false.obs;

  @override
  void onInit() async {
    await fetchPosts();
    listenPostChange();

    super.onInit();
  }

  Future<void> fetchPosts() async {
    loading.value = true;
    final List<dynamic> data =
    await SupabaseService.client.from("posts").select('''
    id ,content , image ,created_at ,comment_count , like_count,user_id,
    user:user_id (email , metadata) , likes:likes (user_id ,post_id)
''').order("id", ascending: false);
    loading.value = false;

    if (data.isNotEmpty) {
      posts.value = [for (var item in data) PostModel.fromJson(item)];
    }
  }

  // * Listen post changes
  void listenPostChange() {
    SupabaseService.client
        .channel('public:posts')
        .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'posts',
        callback: (payload) {
          final newRecord = payload.newRecord;
          final PostModel post = PostModel.fromJson(newRecord);
          updateFeed(post);
                })
        .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'posts',
        callback: (payload) {
          // Access the old record using oldRecord property
          final oldRecord = payload.oldRecord;
          if (oldRecord['id'] != null) {
            posts.removeWhere((element) => element.id == oldRecord['id']);
          }
        })
        .subscribe();
  }

  // * update the home feed
  void updateFeed(PostModel post) async {
    // Check if userId is not null before making the query
    if (post.userId != null) {
      try {
        final user = await SupabaseService.client
            .from("users")
            .select("*")
            .eq("id", post.userId!) // Use ! to assert non-null
            .single();

        // * Fetch likes
        post.likes = [];
        post.user = UserModel.fromJson(user);
        posts.insert(0, post);
      } catch (e) {
        Get.snackbar('Error fetching user:', e.toString());
      }
    } else {
      Get.snackbar('Error', 'Post has no user ID');
    }
  }
}
