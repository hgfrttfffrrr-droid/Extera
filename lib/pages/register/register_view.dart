import 'package:flutter/material.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/register/register.dart';
import 'package:extera_next/widgets/layouts/login_scaffold.dart';

class RegisterView extends StatelessWidget {
  final RegisterController controller;

  const RegisterView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoginScaffold(
      appBar: AppBar(
        leading: controller.loading
            ? null
            : BackButton(onPressed: () => Navigator.of(context).pop()),
        automaticallyImplyLeading: !controller.loading,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text("تکمیل ثبت‌نام"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          // --- بخش اول: دایره عکس پروفایل ---
          Center(
            child: GestureDetector(
              onTap: controller.pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: controller.avatarFile != null
                        ? FileImage(controller.avatarFile!)
                        : null,
                    child: controller.avatarFile == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "برای انتخاب عکس کلیک کنید",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 32),

          // --- بخش دوم: نام و نام خانوادگی ---
          TextField(
            controller: controller.displayNameController,
            decoration: InputDecoration(
              labelText: "نام و نام خانوادگی",
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- بخش سوم: فیلد کد تایید ---
          TextField(
            controller: controller.codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, letterSpacing: 8),
            decoration: InputDecoration(
              labelText: "کد تایید",
              hintText: "- - - - -",
              errorText: controller.codeError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- بخش چهارم: دکمه‌ها ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: controller.loading ? null : controller.verifyCode,
            child: controller.loading
                ? const CircularProgressIndicator()
                : const Text("تایید کد"),
          ),
          const SizedBox(height: 16),

          // دکمه ورود نهایی (بعد از تایید کد)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: controller.loading ? null : controller.completeProfile,
            child: const Text("ورود به برنامه"),
          ),
        ],
      ),
    );
  }
}
