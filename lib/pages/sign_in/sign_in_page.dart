import 'package:flutter/material.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/sign_in/view_model/model/public_homeserver_data.dart';
import 'package:extera_next/pages/sign_in/view_model/sign_in_view_model.dart';
import 'package:extera_next/utils/sign_in_flows/check_homeserver.dart';
import 'package:extera_next/widgets/layouts/login_scaffold.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:extera_next/widgets/view_model_builder.dart';

class SignInPage extends StatelessWidget {
  final bool signUp;
  const SignInPage({required this.signUp, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ViewModelBuilder(
      create: () => SignInViewModel(Matrix.of(context), signUp: signUp),
      builder: (context, viewModel, _) {
        final state = viewModel.value;
        
        // سرور داخلی (مخفی از دید کاربر)
        final defaultHomeserver = PublicHomeserverData(
          name: AppConfig.defaultHomeserver.replaceAll('https://', ''),
        );

        return LoginScaffold(
          appBar: AppBar(
            leading:
                state.loginLoading.connectionState == ConnectionState.waiting
                ? CloseButton(
                    onPressed: () =>
                        viewModel.setLoginLoading(AsyncSnapshot.nothing()),
                  )
                : BackButton(onPressed: Navigator.of(context).pop),
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.surface,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              signUp
                  ? L10n.of(context).createNewAccount
                  : L10n.of(context).login,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  signUp
                      ? L10n.of(context).signUpGreeting
                      : L10n.of(context).signInGreeting,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Material(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed:
                      state.loginLoading.connectionState ==
                          ConnectionState.waiting
                      ? null
                      : () => connectToHomeserverFlow(
                          defaultHomeserver,
                          context,
                          viewModel.setLoginLoading,
                          signUp,
                        ),
                  child:
                      state.loginLoading.connectionState ==
                          ConnectionState.waiting
                      ? const CircularProgressIndicator.adaptive()
                      : Text(L10n.of(context).continueText),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
