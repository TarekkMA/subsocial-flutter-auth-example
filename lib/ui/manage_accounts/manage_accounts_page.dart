import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth/subsocial_auth.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/change_name_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/change_password_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/check_password_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/dialogs/set_signer_dialog.dart';
import 'package:subsocial_auth_example/ui/shared/providers.dart';

class ManageAccountsPage extends ConsumerWidget {
  static const path = '/manage-accounts';

  const ManageAccountsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(subsocialAuthProvider)..update();
    final state = auth.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
      ),
      body: state.accounts.isEmpty
          ? const Center(
              child: Text('There is no accounts'),
            )
          : Column(
              children: [
                const CurrentSignerChecker(),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) {
                      final account = state.accounts[index];
                      final isCurrent = account == state.currentAccount;
                      return AccountWidget(
                        isCurrent: isCurrent,
                        account: account,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

enum AccountWidgetAction {
  setSigner,
  setActiveAccount,
  unsetActiveAccount,
  removeAccount,
  checkPassword,
  changePassword,
  changeName,
}

class AccountWidget extends HookConsumerWidget {
  const AccountWidget({
    Key? key,
    required this.isCurrent,
    required this.account,
  }) : super(key: key);

  final bool isCurrent;
  final AuthAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(subsocialAuthProvider.notifier);
    final isLoading = useState(false);
    return ListTile(
      leading: isLoading.value
          ? const CircularProgressIndicator()
          : Icon(
              isCurrent ? Icons.person : Icons.person_outline,
              color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
            ),
      title: Text(
        account.localName + (isCurrent ? ' (Active)' : ''),
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      subtitle: Text(account.publicKey),
      trailing: PopupMenuButton<AccountWidgetAction>(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: AccountWidgetAction.setSigner,
            child: Text('Set signer'),
          ),
          if (isCurrent)
            const PopupMenuItem(
              value: AccountWidgetAction.unsetActiveAccount,
              child: Text('Unset active'),
            )
          else
            const PopupMenuItem(
              value: AccountWidgetAction.setActiveAccount,
              child: Text('Set active'),
            ),
          const PopupMenuItem(
            value: AccountWidgetAction.removeAccount,
            child: Text('Remove'),
          ),
          const PopupMenuItem(
            value: AccountWidgetAction.checkPassword,
            child: Text('Check password'),
          ),
          const PopupMenuItem(
            value: AccountWidgetAction.changePassword,
            child: Text('Change password'),
          ),
          const PopupMenuItem(
            value: AccountWidgetAction.changeName,
            child: Text('Change name'),
          ),
        ],
        enabled: !isLoading.value,
        onSelected: (value) => _handleAction(
          context,
          auth,
          value,
          isLoading,
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    SubsocialAuth auth,
    AccountWidgetAction action,
    ValueNotifier<bool> loadingNotifier,
  ) async {
    loadingNotifier.value = true;
    switch (action) {
      case AccountWidgetAction.setActiveAccount:
        await auth.setCurrentAccount(account);
        break;
      case AccountWidgetAction.unsetActiveAccount:
        await auth.unsetCurrentAccount();
        break;
      case AccountWidgetAction.removeAccount:
        await auth.removeAccount(account);
        break;
      case AccountWidgetAction.checkPassword:
        await CheckPasswordDialog(account).show(context);
        break;
      case AccountWidgetAction.changePassword:
        await ChangePasswordDialog(account).show(context);
        break;
      case AccountWidgetAction.changeName:
        await ChangeNameDialog(account).show(context);
        break;
      case AccountWidgetAction.setSigner:
        await SetSignerDialog(account).show(context);
        break;
    }

    loadingNotifier.value = false;
  }
}

class CurrentSignerChecker extends HookConsumerWidget {
  const CurrentSignerChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(subsocialAuthProvider.notifier);
    final singerNotifier = useState<AuthAccount?>(null);
    final loadingNotifier = useState(false);
    useEffect(() {
      _fetchCurrentSigner(auth, singerNotifier, loadingNotifier);
    }, []);
    final InlineSpan signerTextSpan;
    if (singerNotifier.value == null) {
      signerTextSpan = const TextSpan(text: 'not set');
    } else {
      final account = singerNotifier.value!;
      signerTextSpan = TextSpan(children: [
        TextSpan(
          text: 'Name: ${account.localName}\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: account.publicKey),
      ]);
    }
    return ListTile(
      leading: Icon(
        Icons.mode_edit,
        color: Theme.of(context).primaryColor,
      ),
      title: const Text(
        'Current Signer',
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text.rich(signerTextSpan),
      trailing: loadingNotifier.value
          ? const CircularProgressIndicator()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (singerNotifier.value != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _clearCurrentSigner(
                        auth, singerNotifier, loadingNotifier),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _fetchCurrentSigner(
                      auth, singerNotifier, loadingNotifier),
                ),
              ],
            ),
    );
  }

  Future<void> _clearCurrentSigner(
    SubsocialAuth auth,
    ValueNotifier<AuthAccount?> singerNotifier,
    ValueNotifier<bool> loadingNotifier,
  ) async {
    loadingNotifier.value = true;
    await auth.unsetSigner();
    singerNotifier.value = null;
    loadingNotifier.value = false;
  }

  Future<void> _fetchCurrentSigner(
    SubsocialAuth auth,
    ValueNotifier<AuthAccount?> singerNotifier,
    ValueNotifier<bool> loadingNotifier,
  ) async {
    loadingNotifier.value = true;
    final signerPublicKey = await auth.currentSignerId();
    final allAccounts = await auth.getAccounts();
    singerNotifier.value = allAccounts
        .where(
          (account) => account.publicKey == signerPublicKey,
        )
        .toList()
        .firstOrNull;
    loadingNotifier.value = false;
  }
}
