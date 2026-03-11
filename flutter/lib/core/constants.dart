class AppConfig {
  static const String apiBaseUrl = 'https://alluring-art-production-5c03.up.railway.app';
  static const String apiProductsUrl = '$apiBaseUrl/api/products/';
  static const String apiCsrfUrl = '$apiBaseUrl/api/auth/csrf/';
  static const String apiMeUrl = '$apiBaseUrl/api/auth/me/';
  static const String apiLoginUrl = '$apiBaseUrl/api/auth/login/';
  static const String apiRegisterUrl = '$apiBaseUrl/api/auth/register/';
  static const String apiLogoutUrl = '$apiBaseUrl/api/auth/logout/';
  static const String logoUrl = '$apiBaseUrl/static/products/img/foesa-logo.png';

  static const Map<String, List<String>> countryCities = {
    'Cameroun': [
      'Douala',
      'Yaounde',
      'Bafoussam',
      'Bamenda',
      'Garoua',
      'Maroua',
      'Ngaoundere',
      'Bertoua',
      'Ebolowa',
      'Kribi',
      'Lembe',
      'Dschang',
      'Kumba',
      'Buea',
      'Edea',
      'Nkongsamba',
    ],
    'Gabon': ['Libreville', 'Port-Gentil', 'Franceville', 'Oyem'],
    'Congo': ['Brazzaville', 'Pointe-Noire', 'Dolisie'],
    'Tchad': ["N'Djamena", 'Moundou', 'Sarh'],
    'France': ['Paris', 'Lyon', 'Marseille', 'Toulouse'],
  };
}
