# FOESA

Site vitrine produits avec:
- Backend: Django + Django REST Framework
- Frontend: React (Vite) + Tailwind CSS

Objectif: exposer un catalogue produits avec contacts (t�l�phone, WhatsApp, email), sans panier ni paiement.

## Architecture

- `backend/`: API, admin Django, interface l�g�re de gestion des produits
- `frontend/`: site vitrine React consommant l�API produits

## Pr�requis

- Python 3.11+
- Node.js 18+ et npm
- PowerShell (Windows) ou shell �quivalent

## Installation et lancement (local)

### 1) Backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py seed_products   # optionnel, charge des exemples
python manage.py runserver
```

Backend local: `http://127.0.0.1:8000/`

### 2) Frontend

```powershell
cd frontend
npm install
npm run dev
```

Frontend local: `http://localhost:5173/`

## Variables d�environnement (Backend)

Le backend lit la configuration depuis les variables d�environnement:

- `SECRET_KEY`: secret Django (obligatoire en production)
- `DEBUG`: `True` ou `False`
- `DATABASE_URL`: URL DB (sinon SQLite local par d�faut)
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

Exemple `.env` (d�veloppement):

```env
SECRET_KEY=dev-secret-change-me
DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
```

Exemple `.env` (production):

```env
SECRET_KEY=replace-with-strong-secret
DEBUG=False
DATABASE_URL=postgres://USER:PASSWORD@HOST:PORT/DBNAME
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
```

Notes:
- Si Cloudinary est configur�, les m�dias utilisent Cloudinary.
- Sinon, stockage local dans `backend/media/`.

## Configuration API c�t� Frontend (important)

Actuellement l�URL API est hardcod�e dans `frontend/src/components/ProductGrid.jsx`.

Il est recommand� de passer par une variable Vite:

```env
VITE_API_URL=http://127.0.0.1:8000/api/products/
```

Puis d�utiliser `import.meta.env.VITE_API_URL` dans le code frontend.

## Endpoints principaux

- API produits (read-only): `GET /api/products/`
- Admin Django: `/admin/`
- Interface l�g�re gestion produits: `/manage/products/`
- Route racine `/` redirige vers `/api/products/`

## Donn�es de d�monstration (`seed_products`)

Commande:

```powershell
python manage.py seed_products
```





## D�ploiement (r�sum�)

Backend:
- `python manage.py migrate`
- `python manage.py collectstatic --noinput`
- Lancer via Gunicorn (pr�sent dans `requirements.txt`) derri�re un proxy


## Commandes utiles

```powershell
# Backend
cd backend
.\.venv\Scripts\Activate.ps1
python manage.py runserver

# Frontend
cd frontend
npm run dev
```

## Fichiers cl�s

- `backend/backend/settings.py`: config Django, DB, CORS, Cloudinary
- `backend/backend/urls.py`: routes principales
- `backend/products/models.py`: modele `Product`
- `backend/products/management/commands/seed_products.py`: import/seed produits
- `frontend/src/components/ProductGrid.jsx`: chargement API c�t� frontend



 l’interface d’admin personnalisée est :

En ligne : https://alluring-art-production-5c03.up.railway.app/manage/products/
En locale : http://127.0.0.1:8000/manage/products/

Et pour gérer :

Ajouter : https://alluring-art-production-5c03.up.railway.app/manage/products/add/
Modifier : https://alluring-art-production-5c03.up.railway.app/manage/products/<id>/edit/
Supprimer : https://alluring-art-production-5c03.up.railway.app/manage/products/<id>/delete/

Ajouter avec Django admin : https://alluring-art-production-5c03.up.railway.app/admin/login/?next=/admin/products/product/ 
NB: ici la connection a ete bloque
