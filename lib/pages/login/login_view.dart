import 'package:flutter/material.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/widgets/layouts/login_scaffold.dart';
import 'login.dart';

class LoginView extends StatelessWidget {
  final LoginController controller;

  const LoginView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoginScaffold(
      appBar: AppBar(
        // دکمه برگشت فقط زمانی نمایش داده میشه که در حال لودینگ نباشیم
        leading: controller.loading ? null : const Center(child: BackButton()),
        automaticallyImplyLeading: !controller.loading,
        titleSpacing: !controller.loading ? 0 : null,
        // عنوان حذف شد تا فقط شماره موبایل دیده بشه
        title: const SizedBox.shrink(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Builder(
        builder: (context) {
          return AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: <Widget>[
                // بنر یا لوگوی اپلیکیشن
                Hero(
                  tag: 'info-logo',
                  child: Image.asset('assets/banner_transparent.png'),
                ),
                const SizedBox(height: 40),

                // متن خوش‌آمدگویی
                Text(
                  "به گپ‌روم خوش آمدید",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "برای ادامه، شماره موبایل خود را وارد کنید",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // فیلد ورودی شماره موبایل با طرح مدرن
                TextField(
                  readOnly: controller.loading,
                  autocorrect: false,
                  autofocus: true,
                  controller: controller.phoneController,
                  textInputAction: TextInputAction.go,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                  onSubmitted: (_) => controller.registerWithPhone(),
                  decoration: InputDecoration(
                    hintText: '0912 345 6789',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                      letterSpacing: 3,
                    ),
                    errorText: controller.phoneError,
                    errorStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.phone_iphone, size: 28),
                  ),
                ),
                const SizedBox(height: 24),

                // دکمه ادامه
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  onPressed: controller.loading ? null : controller.registerWithPhone,
                  child: controller.loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "ادامه",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // بخش راهنمای پایین صفحه (اختیاری)
                Text(
                  "با ادامه، شما شرایط و قوانین را می‌پذیرید.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
