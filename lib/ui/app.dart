import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth_example/ui/create_account/create_account_page.dart';
import 'package:subsocial_auth_example/ui/error/error_page.dart';
import 'package:subsocial_auth_example/ui/home/home_page.dart';
import 'package:subsocial_auth_example/ui/manage_accounts/manage_accounts_page.dart';
import 'package:subsocial_auth_example/ui/shared/theme_notifier.dart';

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = useMemoized(_buildRouter);
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: FlexColorScheme.light(scheme: FlexScheme.ebonyClay).toTheme,
      darkTheme: FlexColorScheme.dark(scheme: FlexScheme.ebonyClay).toTheme,
      routeInformationParser: router.routeInformationParser,
      themeMode: ref.watch(themeProvider),
      routerDelegate: router.routerDelegate,
    );
  }

  GoRouter _buildRouter() => GoRouter(
        routes: [
          GoRoute(
            path: HomePage.path,
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: CreateAccountPage.generatePath,
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const CreateAccountPage(CreateAccountPageType.generate),
            ),
          ),
          GoRoute(
            path: CreateAccountPage.importPath,
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const CreateAccountPage(CreateAccountPageType.import),
            ),
          ),
          GoRoute(
            path: ManageAccountsPage.path,
            pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ManageAccountsPage(),
            ),
          ),
        ],
        errorPageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: ErrorPage(state.error!),
        ),
        initialLocation: HomePage.path,
      );
}
