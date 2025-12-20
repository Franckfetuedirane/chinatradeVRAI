# China Trade Master

Petit site vitrine "China Trade Master" — backend Django + DRF, frontend React (Vite) + Tailwind.

## Objectif

Présenter des produits (images, description, contact) sans panier ni paiement. Back-office léger pour gérer les produits.

## Prérequis

- Python 3.11+ (venv recommandé)
- Node.js + npm

## Backend (Django)

Ouvrir PowerShell et exécuter :

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_products      # (optionnel) remplir d'exemples depuis media/products
python manage.py collectstatic --noinput
python manage.py runserver
```

API et pages locales (backend en `runserver`) :

- Backend (dev): http://127.0.0.1:8000/
- Admin Django: http://127.0.0.1:8000/admin/
- API produits (read-only): http://127.0.0.1:8000/api/products/
- Back-office léger: http://127.0.0.1:8000/manage/products/
- Edit produit exemple (id 40): http://127.0.0.1:8000   
- Media (images uploadées): http://127.0.0.1:8000/media/
- Static collectés: `backend/staticfiles/` (dossier local)

## Frontend (React / Vite)

```powershell
cd frontend
npm install
npm run dev
```

Frontend (dev) : http://localhost:5173/

## Liens distants (exemples)

Remplacez `your-domain.example` par votre domaine réel si vous déployez :

- Site (production) : https://your-domain.example/
- API produits (production) : https://your-domain.example/api/products/

## Fichiers utiles

- `backend/backend/settings.py` — configuration Django (MEDIA_ROOT, STATIC_ROOT, CORS, etc.)
- `backend/media/products/` — images produits
- `frontend/logo china.png` — logo utilisé dans l'en-tête et comme favicon
- `frontend/src/components/Header.jsx` — en-tête (logo + nom)

## Suggestions / recommandations

- Renommer `frontend/logo china.png` pour enlever l'espace (ex. `logo-china.png`) :

```powershell
# depuis la racine du projet
cd frontend
ren "logo china.png" logo-china.png
# puis corriger les imports dans le code (Header.jsx et index.html)
```

- Protéger la partie `/manage/` en ajoutant une authentification (optionnel).
- Ajouter un script de déploiement et config de domaine pour le `STATIC_ROOT` et `MEDIA` en production.

---

Faites-moi savoir si vous voulez :

- que je renomme automatiquement le logo et corrige les imports,
- que j'ajoute la liste complète des routes discovery (ex. routes internes du frontend),
- ou que je génère un `docker-compose` simple pour déployer localement.
