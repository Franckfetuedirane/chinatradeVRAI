# FOESA Mobile (Flutter)

Application mobile FOESA connectee a l'API production:
- API: https://alluring-art-production-5c03.up.railway.app/api/products/
- Logo: https://alluring-art-production-5c03.up.railway.app/static/products/img/foesa-logo.png

## Fonctionnalites
- Catalogue produits (cards modernes)
- Recherche texte + filtres categorie/pays/ville
- Fiche produit detaillee (galerie + video)
- Chariot avec quantites
- Pays de livraison + villes dynamiques
- Persistance locale du chariot

## Prerequis
- Flutter SDK 3.22+

## Installation
Depuis le dossier `flutter/`:

```bash
flutter create .
flutter pub get
flutter run
```

> `flutter create .` est necessaire si le dossier a ete cree manuellement sans les sous-dossiers Android/iOS.

## Build release Android

```bash
flutter build apk --release
```

## Structure
- `lib/core/constants.dart`: config API et pays/villes
- `lib/models/`: modeles produit et chariot
- `lib/services/`: API + stockage local
- `lib/state/shop_state.dart`: etat global application
- `lib/screens/`: home, catalogue, detail, chariot
- `lib/widgets/product_card.dart`: carte produit
