import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';
import 'package:matrix/matrix_api_lite/utils/logs.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/config/app_settings.dart';
import 'package:extera_next/pages/sign_in/view_model/model/public_homeserver_data.dart';
import 'package:extera_next/pages/sign_in/view_model/sign_in_state.dart';
import 'package:extera_next/widgets/matrix.dart';

class SignInViewModel extends ValueNotifier<SignInState> {
  final MatrixState matrixService;
  final bool signUp;
  final TextEditingController filterTextController = TextEditingController();

  SignInViewModel(this.matrixService, {required this.signUp})
    : super(SignInState()) {
    // به جای دانلود لیست سرورها، مستقیم فقط سرور خودمان را تنظیم می‌کنیم
    _setupCustomHomeserver();
    filterTextController.addListener(_filterHomeservers);
  }

  @override
  void dispose() {
    filterTextController.removeListener(_filterHomeservers);
    filterTextController.dispose();
    super.dispose();
  }

  // --- تابع جدید برای تنظیم سرور اختصاصی ---
  void _setupCustomHomeserver() {
    final defaultHomeserverData = PublicHomeserverData(
      name: AppSettings.defaultHomeserver.value,
    );
    
    // فقط سرور خودمان را در لیست قرار می‌دهیم
    value = value.copyWith(
      selectedHomeserver: defaultHomeserverData,
      publicHomeservers: AsyncSnapshot.withData(ConnectionState.done, [
        defaultHomeserverData,
      ]),
      filteredPublicHomeservers: [defaultHomeserverData],
    );
  }

  void _filterHomeservers() {
    // چون فقط یک سرور داریم، فیلتر نیازی نیست، ولی برای جلوگیری از خطا خالی می‌گذاریم
  }

  void selectHomeserver(PublicHomeserverData? publicHomeserverData) {
    value = value.copyWith(selectedHomeserver: publicHomeserverData);
  }

  void setLoginLoading(AsyncSnapshot<bool> loginLoading) {
    value = value.copyWith(loginLoading: loginLoading);
  }
}
