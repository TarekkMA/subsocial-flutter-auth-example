import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth/subsocial_auth.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/app_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/providers.dart';

class ChangeNameDialog extends AppDialog<void> {
  final AuthAccount _account;

  const ChangeNameDialog(this._account) : super(hookWidget: true);

  @override
  String get title => 'Change Name';

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> loadingNotifier,
    ValueNotifier<String?> errorNotifier,
  ) {
    final nameController = useTextEditingController();
    final isLoading = useValueListenable(loadingNotifier);
    return Column(
      children: [
        TextField(
          controller: nameController,
          enabled: !isLoading,
          decoration: const InputDecoration(labelText: 'New name'),
        ),
        AppDialogActionButton(
          label: 'Change',
          loadingNotifier: loadingNotifier,
          action: () async {
            final auth = ref.read(subsocialAuthProvider.notifier);

            final name = nameController.text;
            if (name.isEmpty) {
              errorNotifier.value = 'Name cannot be empty';
              return;
            }
            loadingNotifier.value = true;
            try {
              await auth.changeName(_account, name);
              Navigator.of(context).pop();
            } catch (e, stk) {
              errorNotifier.value = e.toString();
              log(
                'error while changing name',
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
