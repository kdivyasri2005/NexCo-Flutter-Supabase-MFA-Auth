import 'package:get/get.dart';
import 'package:nexco/utils/env.dart';
import 'package:nexco/utils/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() async {
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);
    currentUser.value = client.auth.currentUser;

    listenAuthChange();
    super.onInit();
  }

  // * Create Signle Instance
  static final SupabaseClient client = Supabase.instance.client;

  // * first load the status
  void updateUserfromSession() {
    var session = Session.fromJson(StorageService.userSession!);
    currentUser.value = session?.user;
  }

  // *  listen auth changes
  void listenAuthChange() {
    client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.userUpdated) {
        currentUser.value = data.session?.user;
      } else if (event == AuthChangeEvent.signedIn) {
        currentUser.value = data.session?.user;
      }
    });
  }
}
