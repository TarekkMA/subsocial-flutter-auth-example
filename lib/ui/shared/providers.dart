import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsocial_auth/subsocial_auth.dart';
import 'package:subsocial_sdk/subsocial_sdk.dart';

final subsocialSdkProvider = Provider<Subsocial>((ref) {
  throw Exception('Provider was not initialized');
});

final subsocialAuthProvider = ChangeNotifierProvider<SubsocialAuth>((ref) {
  throw Exception('Provider was not initialized');
});

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw Exception('Provider was not initialized');
});

Future<List<Override>> initializeProviders() async {
  final sdk = await Subsocial.instance;
  final auth = await SubsocialAuth.defaultConfiguration(sdk: sdk);
  final prefs = await SharedPreferences.getInstance();
  return [
    subsocialSdkProvider.overrideWithValue(sdk),
    subsocialAuthProvider.overrideWithValue(auth),
    sharedPrefsProvider.overrideWithValue(prefs),
  ];
}
