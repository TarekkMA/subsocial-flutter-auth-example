import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth/subsocial_auth.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/app_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/providers.dart';

class SetSignerDialog extends AppDialog<void> {
  final AuthAccount _account;

  const SetSignerDialog(this._account) : super(hookWidget: true);

  @override
  String get title => 'Set Signer';

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> loadingNotifier,
    ValueNotifier<String?> errorNotifier,
  ) {
    final auth = ref.watch(subsocialAuthProvider.notifier);
    final passwordController = useTextEditingController();
    final isLoading = useValueListenable(loadingNotifier);
    return Column(
      children: [
        TextField(
          controller: passwordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        AppDialogActionButton(
          label: 'Set signer',
          loadingNotifier: loadingNotifier,
          action: () async {
            final password = passwordController.text;
            if (password.isEmpty) {
              errorNotifier.value = 'Password cannot be empty';
              return;
            }
            loadingNotifier.value = true;
            try {
              final isCorrect = await auth.setSigner(_account, password);
              if (isCorrect) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signer changed')));
              } else {
                errorNotifier.value = 'incorrect password';
              }
            } catch (e, stk) {
              errorNotifier.value = e.toString();
              log(
                'error while setting signer',
                error: e,
                stackTrace: stk,
              );
            }
            loadingNotifier.value = false;
          },
        )
      ],
    );
  }
}
