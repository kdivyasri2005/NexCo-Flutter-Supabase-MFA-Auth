import 'package:get/get.dart';
import 'package:nexco/routes/route_names.dart';
import 'package:nexco/services/supabase_service.dart';
import 'package:nexco/utils/helper.dart';
import 'package:nexco/utils/storage/storage_keys.dart';
import 'package:nexco/utils/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final registerLoading = false.obs;
  final loginLoading = false.obs;

  // * Register Method
  Future<void> register(String name, String email, String password) async {
    registerLoading.value = true;
    final AuthResponse response = await SupabaseService.client.auth
        .signUp(email: email, password: password, data: {"name": name});
    registerLoading.value = false;

    if (response.user != null) {
      StorageService.session.write(StorageKeys.userSession, response.session!.toJson());
      Get.offAllNamed(RouteNames.home);
    } else {
      showSnackBar("Error", "Something went wrong");
    }
  }

  // * Login user
  Future<void> login(String email, String password) async {
    loginLoading.value = true;
    try {
      final AuthResponse response = await SupabaseService.client.auth
          .signInWithPassword(email: email, password: password);
      loginLoading.value = false;
      if (response.user != null) {
        StorageService.session.write(StorageKeys.userSession, response.session!.toJson());
        Get.offAllNamed(RouteNames.otpCode);
      }
    } on AuthException catch (error) {
      loginLoading.value = false;
      showSnackBar("Error", error.message);
    } catch (error) {
      loginLoading.value = false;
      showSnackBar("Error", "Something went wrong.please try again.");
    }
  }
}
