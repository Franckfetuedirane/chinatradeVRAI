import 'package:http/browser_client.dart';

BrowserClient createPlatformHttpClient({bool withCredentials = false}) {
  final client = BrowserClient()..withCredentials = withCredentials;
  return client;
}
