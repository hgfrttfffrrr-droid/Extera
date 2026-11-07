import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/utils/clean_exif.dart';
import 'package:extera_next/utils/platform_infos.dart';
import 'register_view.dart';

class Register extends StatefulWidget {
  final Client client;
  final String? phone;
  const Register({required this.client, this.phone, super.key});

  @override
  RegisterController createState() => RegisterController();
}

class RegisterController extends State<Register> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  
  String? codeError;
  bool loading = false;
  XFile? avatarFile;
  
  String? _session;

  @override
  void initState() {
    super.initState();
    // اگر شماره از صفحه قبل اومده باشه، درخواست کد می‌فرستیم
    if (widget.phone != null) {
      _requestCode(widget.phone!);
    }
  }

  Future<void> _requestCode(String phone) async {
    setState(() => loading = true);
    try {
      // درخواست ثبت‌نام با شماره موبایل
      final response = await widget.client.register(
        username: null,
        password: null,
        initialDeviceDisplayName: PlatformInfos.clientName,
        auth: AuthenticationThreePidCreds(
          type: AuthenticationTypes.msisdn,
          threepidCreds: ThreepidCreds(
            sid: '',
            clientSecret: '',
          ),
        ),
      );
      
      // --- خطوط session کامنت شدند (چون در نسخه جدید وجود نداره) ---
      // if (response.session != null) {
      //   _session = response.session;
      // }
      
    } catch (e) {
      debugPrint("Error requesting code: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // --- مرحله ۲: تایید کد ---
  Future<void> verifyCode() async {
    if (codeController.text.isEmpty) {
      setState(() => codeError = "لطفاً کد تایید را وارد کنید");
      return;
    }

    setState(() {
      loading = true;
      codeError = null;
    });

    try {
      // ارسال کد به سرور برای بررسی
      await widget.client.register(
        username: null,
        password: null,
        initialDeviceDisplayName: PlatformInfos.clientName,
        auth: AuthenticationThreePidCreds(
          type: AuthenticationTypes.msisdn,
          threepidCreds: ThreepidCreds(
            sid: _session ?? '',
            clientSecret: codeController.text.trim(),
          ),
        ),
      );

      if (mounted) {
        setState(() => loading = false);
        // اگر کد درست بود، برو به مرحله پروفایل
      }
    } on MatrixException catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        codeError = e.errorMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        codeError = e.toString();
      });
    }
  }

  // --- مرحله ۳: انتخاب عکس پروفایل ---
  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => avatarFile = picked);
  }

  // --- مرحله ۴: ذخیره پروفایل و ورود ---
  Future<void> completeProfile() async {
    setState(() => loading = true);

    try {
      final displayName = displayNameController.text.trim();
      
      if (displayName.isNotEmpty) {
        await widget.client.setProfileField(widget.client.userID!, 'displayname', {
          'displayname': displayName,
        });
      }

      if (avatarFile != null) {
        final bytes = Uint8List.fromList(
          ExifCleaner.removeExifData(await avatarFile!.readAsBytes()),
        );
        final mimeType = avatarFile!.mimeType ?? 'image/png';
        final uploaded = await widget.client.uploadContent(
          bytes,
          filename: avatarFile!.name,
          contentType: mimeType,
        );
        await widget.client.setProfileField(widget.client.userID!, 'avatar_url', {
          'avatar_url': uploaded.toString(),
        });
      }
    } catch (e) {
      debugPrint('Failed to set profile: $e');
    }

    if (!mounted) return;
    setState(() => loading = false);
    context.go('/rooms'); // ورود به صفحه اصلی
  }

  @override
  void dispose() {
    codeController.dispose();
    displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RegisterView(this);
}
