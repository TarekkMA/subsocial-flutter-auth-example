import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial_auth_example/ui/app.dart';
import 'package:subsocial_auth_example/ui/shared/providers.dart';

void main() async {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );

  final overrides = await initializeProviders();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const App(),
    ),
  );
}
