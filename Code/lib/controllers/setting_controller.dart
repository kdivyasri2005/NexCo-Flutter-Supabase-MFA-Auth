import 'package:get/get.dart';
import 'package:nexco/routes/route_names.dart';
import 'package:nexco/services/otp_service.dart';
import 'package:nexco/services/supabase_service.dart';
import 'package:nexco/utils/storage/storage_keys.dart';
import 'package:nexco/utils/storage/storage_service.dart';


class SettingController extends GetxController {
  AuthServices get authService => Get.find<AuthServices>();

  Future<void> logout() async {
    try {
      StorageService.session.remove(StorageKeys.userSession);


      // Sign out from both services simultaneously

     await SupabaseService.client.auth.signOut();
     await authService.client().auth.signOut();
    Get.offAllNamed(RouteNames.login);

    } catch (error, stackTrace) {
    // Log the error for debugging
    Get.log('Logout failed: $error\n$stackTrace', isError: true);
    // Show user-friendly error message
    Get.snackbar(
    'Logout Error',
    'Could not complete logout. Please try again.',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    );

    // Optional: Re-throw if you have error monitoring
    // throw e;
    }
  }
}