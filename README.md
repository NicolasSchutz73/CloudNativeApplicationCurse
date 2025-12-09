# Gym Management System

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=bugs)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=coverage)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)

A complete fullstack gym management application built with modern web technologies.

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gym-management-system
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file if needed (default values should work for development).

3. **Start the application**
   ```bash
   docker-compose up --build
   ```

4. **Access the application**
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:3000
   - Database: localhost:5432

### Default Login Credentials

The application comes with seeded test data:

**Admin User:**
- Email: admin@gym.com
- Password: admin123
- Role: ADMIN

**Regular Users:**
- Email: john.doe@email.com
- Email: jane.smith@email.com  
- Email: mike.wilson@email.com
- Password: password123 (for all users)

## Project Structure

```
gym-management-system/
├── backend/
│   ├── src/
│   │   ├── controllers/     # Request handlers
│   │   ├── services/        # Business logic
│   │   ├── repositories/    # Data access layer
│   │   ├── routes/          # API routes
│   │   └── prisma/          # Database schema and client
│   ├── seed/                # Database seeding
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── views/           # Vue components/pages
│   │   ├── services/        # API communication
│   │   ├── store/           # Pinia stores
│   │   └── router/          # Vue router
│   ├── Dockerfile
│   └── nginx.conf
└── docker-compose.yml
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Classes
- `GET /api/classes` - Get all classes
- `GET /api/classes/:id` - Get class by ID
- `POST /api/classes` - Create class
- `PUT /api/classes/:id` - Update class
- `DELETE /api/classes/:id` - Delete class

### Bookings
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/user/:userId` - Get user bookings
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id/cancel` - Cancel booking
- `DELETE /api/bookings/:id` - Delete booking

### Subscriptions
- `GET /api/subscriptions` - Get all subscriptions
- `GET /api/subscriptions/user/:userId` - Get user subscription
- `POST /api/subscriptions` - Create subscription
- `PUT /api/subscriptions/:id` - Update subscription

### Dashboard
- `GET /api/dashboard/user/:userId` - Get user dashboard
- `GET /api/dashboard/admin` - Get admin dashboard

## Development

### Local Development Setup

1. **Backend Development**
   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. **Frontend Development**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. **Database Setup**
   ```bash
   cd backend
   npx prisma migrate dev
   npm run seed
   ```

### Database Management

- **View Database**: `npx prisma studio`
- **Reset Database**: `npx prisma db reset`
- **Generate Client**: `npx prisma generate`
- **Run Migrations**: `npx prisma migrate deploy`

### Useful Commands

```bash
# Stop all containers
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Rebuild specific service
docker-compose up --build [service-name]

# Access database
docker exec -it gym_db psql -U postgres -d gym_management
```

## Features in Detail

### Subscription System
- **STANDARD**: €30/month, €5 per no-show
- **PREMIUM**: €50/month, €3 per no-show  
- **ETUDIANT**: €20/month, €7 per no-show

### Booking Rules
- Users can only book future classes
- Maximum capacity per class is enforced
- No double-booking at the same time slot
- 2-hour cancellation policy

### Admin Dashboard
- Total users and active subscriptions
- Booking statistics (confirmed, no-show, cancelled)
- Monthly revenue calculations
- User management tools

### User Dashboard
- Personal statistics and activity
- Current subscription details
- Monthly billing with no-show penalties
- Recent booking history

## Git Workflow & Conventions

### Branch Strategy

**Branches principales :**
- `main` - Production-ready code, protected
- `develop` - Integration branch for features

**Branches de feature :**
- Format: `feature/<nom-de-la-fonctionnalite>`
- Exemple: `feature/user-authentication`, `feature/booking-system`

**Règles de protection :**
- ❌ Pas de commit direct sur `main` ou `develop`
- ✅ Pull Request obligatoire vers `develop`
- ✅ Status checks requis avant merge
- ✅ Review requise (optionnel mais recommandé)

### Convention de Commit

Ce projet utilise [Conventional Commits](https://www.conventionalcommits.org/) avec **commitlint**.

**Format obligatoire :**
```
<type>: <description>

[corps optionnel]

[footer optionnel]
```

**Types acceptés :**
- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `chore:` - Tâches de maintenance (dépendances, config, etc.)
- `docs:` - Documentation
- `style:` - Formatage du code (sans changement de logique)
- `refactor:` - Refactorisation du code
- `perf:` - Amélioration des performances
- `test:` - Ajout ou modification de tests
- `build:` - Changements du système de build
- `ci:` - Changements de configuration CI/CD
- `revert:` - Annulation d'un commit précédent

**Exemples valides :**
```bash
feat: ajout de l'authentification utilisateur
fix: correction de la connexion Postgres
chore: mise à jour des dépendances NestJS
docs: mise à jour du README avec les règles Git
style: formatage du code frontend avec ESLint
refactor: réorganisation de la structure des services
perf: optimisation des requêtes database
test: ajout des tests unitaires pour UserService
ci: configuration du workflow GitHub Actions
```

**Exemples invalides :**
```bash
❌ ajout feature (pas de type)
❌ feat : ajout feature (espace avant :)
❌ FEAT: ajout feature (majuscule)
❌ lol: test (type non reconnu)
```

### Hooks Git (Husky)

**`pre-commit`** - Exécuté avant chaque commit
- ✅ Lint frontend (ESLint)
- ✅ Lint backend (si configuré)
- Bloque le commit en cas d'erreur de lint

**`commit-msg`** - Exécuté lors de la création du message de commit
- ✅ Validation du format Conventional Commits
- ✅ Vérifie le type, la description
- Bloque le commit si le format est invalide

### Workflow de Contribution

1. **Créer une branche de feature**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/ma-nouvelle-feature
   ```

2. **Développer et commiter**
   ```bash
   # Les hooks pre-commit et commit-msg s'exécutent automatiquement
   git add .
   git commit -m "feat: ajout de la nouvelle fonctionnalité"
   ```

3. **Pousser et créer une Pull Request**
   ```bash
   git push origin feature/ma-nouvelle-feature
   ```
   - Créer une PR vers `develop` sur GitHub
   - Les status checks CI s'exécutent automatiquement
   - Attendre l'approbation et le passage des checks

4. **Merge vers develop**
   - Une fois approuvée et les checks validés
   - Utiliser "Squash and merge" ou "Merge commit"
   - Supprimer la branche de feature

5. **Release vers main**
   - Créer une PR de `develop` vers `main`
   - Tests et validations finales
   - Merge uniquement quand prêt pour la production

### CI/CD Pipeline

**GitHub Actions workflows :**
- ✅ **Lint** - Vérifie le code frontend et backend avec ESLint
- ✅ **Build** - Compile frontend et backend
- ✅ **Tests** - Exécute les tests backend
- ✅ **SonarCloud** - Analyse qualité du code backend avec Quality Gate

**Pipeline Jobs (tous sur self-hosted runner) :**
1. **Lint Job** : Vérifie la qualité du code (frontend + backend)
2. **Build Job** : Compile les applications (frontend + backend)
3. **Test Job** : Exécute les tests unitaires backend
4. **SonarCloud Job** : Analyse de code et Quality Gate

**Status checks requis :**
- Tous les jobs CI doivent passer avant merge
- SonarCloud Quality Gate doit être validé
- Branch doit être à jour avec la branche cible

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.


## TP 3 : 

PART 1 : 
![img.png](img.png)

![img_1.png](img_1.png)

PART 2 :

![img_2.png](img_2.png)

