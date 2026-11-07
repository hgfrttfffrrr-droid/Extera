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

    // فرمت‌دهی شماره
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
      
      // درخواست ثبت‌نام با شماره موبایل
      await client.register(
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

      if (mounted) {
        // در صورت نیاز به کد تایید، به صفحه بعد برو
        // (فعلاً برای سادگی، فرض می‌کنیم سرور قبول کرده)
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

extension on String {
  static final RegExp _phoneRegex = RegExp(
    r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
  );
  static final RegExp _emailRegex = RegExp(r'(.+)@(.+)\.(.+)');

  bool get isEmail => _emailRegex.hasMatch(this);

  bool get isPhoneNumber => _phoneRegex.hasMatch(this);
}
