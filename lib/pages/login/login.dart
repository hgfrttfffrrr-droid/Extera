import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/utils/localized_exception_extension.dart';
import 'package:extera_next/widgets/matrix.dart';
import '../../utils/platform_infos.dart';
import 'login_view.dart';

class Login extends StatefulWidget {
  final Client client;
  const Login({required this.client, super.key});

  @override
  LoginController createState() => LoginController();
}

class LoginController extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  String? phoneError;
  bool loading = false;

  Future<void> registerWithPhone() async {
    if (phoneController.text.isEmpty) {
      setState(() => phoneError = "لطفاً شماره موبایل خود را وارد کنید");
      return;
    }

    // فرمت‌دهی شماره (مثلاً 09123456789 به +989123456789)
    String phone = phoneController.text.trim();
    if (phone.startsWith('0')) {
      phone = '+98${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+98$phone';
    }

    setState(() {
      loading = true;
      phoneError = null;
    });

    try {
      final client = await Matrix.of(context).getLoginClient();
      
      // ارسال درخواست به سرور برای ثبت‌نام با شماره
      final response = await client.register(
        username: null,
        password: null, // رمز عبور نداریم، از کد تایید استفاده می‌کنیم
        initialDeviceDisplayName: PlatformInfos.clientName,
        auth: AuthenticationThreePidCreds(
          type: AuthenticationTypes.registrationToken,
          session: null,
        ),
        // درخواست ارسال کد به شماره
        threepidCreds: ThreepidCreds(
          sid: null,
          clientSecret: null,
        ),
      );

      // اگر سرور کد را ارسال کرد، به صفحه تایید برو
      if (mounted) {
        context.go('/register/verify', extra: {'phone': phone, 'client': client});
      }
    } on MatrixException catch (exception) {
      setState(() => phoneError = exception.errorMessage);
    } catch (exception) {
      setState(() => phoneError = exception.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LoginView(this);
}
