import 'package:http/http.dart' as http;

http.Client createPlatformHttpClient({bool withCredentials = false}) {
  return http.Client();
}
