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
