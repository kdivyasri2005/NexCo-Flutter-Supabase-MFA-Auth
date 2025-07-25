import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices extends GetxService {
  final SupabaseClient otpClient;

  AuthServices(this.otpClient);

  SupabaseClient client() {
    return otpClient;
  }
}