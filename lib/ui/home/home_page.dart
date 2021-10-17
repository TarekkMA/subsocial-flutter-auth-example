import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth_example/ui/create_account/create_account_page.dart';
import 'package:subsocial_auth_example/ui/manage_accounts/manage_accounts_page.dart';
import 'package:subsocial_auth_example/ui/shared/theme_notifier.dart';

class HomePage extends StatelessWidget {
  static const path = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subsocial Auth Example'),
        actions: const [
          _ThemeSwitcherWidget(),
        ],
      ),
      body: ListView(
        children: [
          _HomePageItem(
            text: 'Create new account',
            onTap: () {
              context.push(CreateAccountPage.generatePath);
            },
          ),
          _HomePageItem(
            text: 'Import account account',
            onTap: () {
              context.push(CreateAccountPage.importPath);
            },
          ),
          _HomePageItem(
            text: 'Manage accounts',
            onTap: () {
              context.push(ManageAccountsPage.path);
            },
          )
        ],
      ),
    );
  }
}

class _HomePageItem extends StatelessWidget {
  final String text;
  final GestureTapCallback? onTap;

  const _HomePageItem({
    Key? key,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        title: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.navigate_next),
      ),
    );
  }
}

class _ThemeSwitcherWidget extends ConsumerWidget {
  const _ThemeSwitcherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);
    return IconButton(
      onPressed: () {
        themeNotifier.change(
          // cycle through themes
          ThemeMode.values[(currentTheme.index + 1) % ThemeMode.values.length],
        );
      },
      icon: Icon(_getThemeIcon(currentTheme)),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.brightness_high_rounded;
      case ThemeMode.dark:
        return Icons.brightness_2_rounded;
    }
  }
}
