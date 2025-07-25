import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nexco/controllers/auth_controller.dart';
import 'package:nexco/routes/routes.dart';
import 'package:nexco/routes/route_names.dart';
import 'package:nexco/services/otp_service.dart';
import 'package:nexco/services/supabase_service.dart';

import 'package:nexco/utils/env.dart';
import 'package:nexco/utils/storage/storage_service.dart';
import 'package:nexco/utils/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await GetStorage.init();

  // Initialize only ONCE
  // Create OTP client without initialization
  final otpClient = SupabaseClient(Env.otpUrl, Env.otpKey);

  Get.put(SupabaseService());
  Get.put(AuthServices(otpClient));
  //Get.lazyPut(()=> AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexCo',
      theme: theme,
      getPages: Routes.routes,
      initialRoute:StorageService.userSession != null?RouteNames.home:RouteNames.login,
      defaultTransition: Transition.noTransition,
    );
  }
}