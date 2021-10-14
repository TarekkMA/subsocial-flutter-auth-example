import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth/subsocial_auth.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/app_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/providers.dart';

class ChangePasswordDialog extends AppDialog<void> {
  final AuthAccount _account;

  const ChangePasswordDialog(this._account) : super(hookWidget: true);

  @override
  String get title => 'Change Password';

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> loadingNotifier,
    ValueNotifier<String?> errorNotifier,
  ) {
    final passwordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final isLoading = useValueListenable(loadingNotifier);
    return Column(
      children: [
        TextField(
          controller: passwordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        TextField(
          controller: newPasswordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        AppDialogActionButton(
          label: 'Change Password',
          loadingNotifier: loadingNotifier,
          action: () async {
            final auth = ref.read(subsocialAuthProvider.notifier);

            final password = passwordController.text;
            final newPassword = newPasswordController.text;
            if (password.isEmpty || newPassword.isEmpty) {
              errorNotifier.value = 'Fields cannot be empty';
              return;
            }
            loadingNotifier.value = true;
            try {
              final newAcc =
                  await auth.changePassword(_account, password, newPassword);
              if (newAcc != null) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password have changed')));
              } else {
                errorNotifier.value = 'incorrect old password';
              }
            } catch (e, stk) {
              errorNotifier.value = e.toString();
              log(
                'error while changing password',
                error: e,
                stackTrace: stk,
              );
            }
            loadingNotifier.value = false;
          },
        ),
      ],
    );
  }
}
