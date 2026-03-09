class AppConfig {
  static const String apiProductsUrl =
      'https://alluring-art-production-5c03.up.railway.app/api/products/';
  static const String logoUrl =
      'https://alluring-art-production-5c03.up.railway.app/static/products/img/foesa-logo.png';

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
