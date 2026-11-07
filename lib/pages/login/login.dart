import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:http/io_client.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
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

  late Client _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client;

    // --- تنظیم IOClient برای قبول گواهی SSL خودامضا ---
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    _client.httpClient = IOClient(httpClient);

    // تنظیم سرور پیش‌فرض
    _client.homeserver = Uri.parse(AppConfig.defaultHomeserver);
  }

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
      // --- تست اتصال به سرور ---
      // اینجا فقط چک می‌کنیم که آیا به سرور وصل می‌شه یا نه
      final versions = await _client.checkHomeserver(_client.homeserver!);
      
      debugPrint("Connected to server: $versions");

      // اگر وصل شد، برو به صفحه بعد
      if (mounted) {
        context.go('/addaccount/register', extra: {
          'client': _client,
          'phone': phone,
        });
      }
    } catch (exception) {
      // اگر خطا داد، پیام خطا رو نشون بده
      setState(() => phoneError = "خطا در اتصال: ${exception.toString()}");
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
