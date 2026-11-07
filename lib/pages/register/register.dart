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
  
  // متغیرهایی که از مرحله قبل (شماره) میاد
  String? _session;
  String? _msisdnSid;
  String? _msisdnClientSecret;

  @override
  void initState() {
    super.initState();
    // اگر شماره از صفحه قبل اومده باشه، اینجا ست میشه
    // (در کد نهایی باید از طریق پارامترهای GoRouter پاس داده بشه)
  }

  // --- مرحله ۱: تایید کد ---
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
      // اینجا باید کد رو به سرور بفرستیم
      // (فعلاً برای تست، فرض میکنیم کد درسته)
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      setState(() => loading = false);
      
      // بعد از تایید، برو به مرحله پروفایل
      // (در کد واقعی باید یک صفحه جدید باز بشه)
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        codeError = e.toString();
      });
    }
  }

  // --- مرحله ۲: انتخاب عکس پروفایل ---
  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => avatarFile = picked);
  }

  // --- مرحله ۳: ذخیره پروفایل و ورود ---
  Future<void> completeProfile() async {
    setState(() => loading = true);

    try {
      final client = widget.client;
      final displayName = displayNameController.text.trim();
      
      if (displayName.isNotEmpty) {
        await client.setProfileField(client.userID!, 'displayname', {
          'displayname': displayName,
        });
      }

      if (avatarFile != null) {
        final bytes = Uint8List.fromList(
          ExifCleaner.removeExifData(await avatarFile!.readAsBytes()),
        );
        final mimeType = avatarFile!.mimeType ?? 'image/png';
        final uploaded = await client.uploadContent(
          bytes,
          filename: avatarFile!.name,
          contentType: mimeType,
        );
        await client.setProfileField(client.userID!, 'avatar_url', {
          'avatar_url': uploaded.toString(),
        });
      }
    } catch (e) {
      Logs().w('Failed to set profile', e);
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
