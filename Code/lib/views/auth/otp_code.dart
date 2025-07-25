import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:nexco/routes/route_names.dart';
import 'package:nexco/services/otp_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class OtpCode extends StatefulWidget {
  const OtpCode({super.key});
  @override
  State<OtpCode> createState() => _OtpCodeState();}
class _OtpCodeState extends State<OtpCode> {
  final phoneNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String otpCode = '';
  bool isResendEnabled = true;
  int resendTimeout = 60;
  late Timer timer;
  bool isLoading = false;
  @override
  void dispose() {
    timer.cancel();
    phoneNumberController.dispose();
    super.dispose();}
  void startTimer() {
    setState(() {isResendEnabled = false;resendTimeout = 60;});
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (resendTimeout <= 0) {t.cancel();
        setState(() => isResendEnabled = true);
      } else {
        setState(() => resendTimeout--);}});}
  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final authService = Get.find<AuthServices>();
    try {
      await authService.client().auth.signInWithOtp(
        phone: phoneNumberController.text.trim(),);
      startTimer();
      Get.snackbar('Success', 'OTP Sent Successfully');
    } on AuthException catch (e) {
      String message = 'Failed to send OTP';
      if (e.message.contains('unverified')) {
        message = 'This number needs verification with Twilio first';
      } else if (e.statusCode == '429') {
        message = 'Please wait before requesting another OTP';}
      Get.snackbar('Error', message);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      setState(() => isLoading = false);}}
  Future<void> verifyOtp() async {
    if (otpCode.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;}
    setState(() => isLoading = true);
    final authService = Get.find<AuthServices>();
    try {
      final response = await authService.client().auth.verifyOTP(
        phone: phoneNumberController.text.trim(),
        token: otpCode,
        type: OtpType.sms,);
      if (response.user != null) {
        Get.offAllNamed(RouteNames.home);}
    } on AuthException catch (e) {
      Get.snackbar('Verification Failed', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Verification failed. Please try again.');
    } finally {
      setState(() => isLoading = false);}}
  @override
  Widget build(BuildContext context) {return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25,),),
        centerTitle: true, backgroundColor: Colors.blue,),
      body: Padding(padding: const EdgeInsets.all(16.0),
        child: Form(key: formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [TextFormField(controller: phoneNumberController,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Phone number is required' : null,
                decoration: InputDecoration(
                  label: const Text('Phone Number'),
                  hintText: "+91-##########",
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),),),
                keyboardType: TextInputType.phone,),
              const SizedBox(height: 20), SizedBox(width: 300,
                child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),),),
                  onPressed: isResendEnabled && !isLoading ? sendOtp : null,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isResendEnabled ? "Send OTP"
                        : "Resend OTP in $resendTimeout sec",
                    style: const TextStyle(color: Colors.white),),),),
              const SizedBox(height: 20), OtpTextField(numberOfFields: 6,
                borderColor: Colors.blue, showFieldAsBox: true,
                onSubmit: (code) => setState(() => otpCode = code),),
              const SizedBox(height: 20),
              SizedBox(width: 300,
                child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),),),
                  onPressed: !isLoading ? verifyOtp : null,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm OTP",
                    style: TextStyle(color: Colors.white),),),),],),),),);}}