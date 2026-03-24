# Gym Management System

[![CI Pipeline](https://github.com/NicolasSchutz73/CloudNativeApplicationCurse/actions/workflows/ci.yml/badge.svg)](https://github.com/NicolasSchutz73/CloudNativeApplicationCurse/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=bugs)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=NicolasSchutz73_CloudNativeApplicationCurse&metric=coverage)](https://sonarcloud.io/summary/new_code?id=NicolasSchutz73_CloudNativeApplicationCurse)

## 🚀 Quick Start with Docker Compose

### Prerequisites
- Docker and Docker Compose installed
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/NicolasSchutz73/CloudNativeApplicationCurse.git
   cd CloudNativeApplicationCurse
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` file if needed (default values should work for development).

3. **Start the application with Docker Compose**
   ```bash
   docker compose up --build
   ```

4. **Access the application**
   - **Frontend**: http://localhost:8080
   - **Backend API**: http://localhost:3000
   - **PostgreSQL Database**: localhost:5432 (internal only)

5. **Verify the stack is running**
   ```bash
   docker compose ps
   ```

### Stop the application
```bash
docker compose down

# To remove volumes as well (reset database)
docker compose down -v
```

## 🐳 Docker Images

Pre-built Docker images are available on GitHub Container Registry (GHCR):

### Pull Images

```bash
# Backend
docker pull ghcr.io/nicolasschutz73/cloudnative-backend:latest

# Frontend
docker pull ghcr.io/nicolasschutz73/cloudnative-frontend:latest
```

### Run Images Directly

**Backend:**
```bash
docker run -d -p 3000:3000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  -e NODE_ENV=production \
  ghcr.io/nicolasschutz73/cloudnative-backend:latest
```

**Frontend:**
```bash
docker run -d -p 8080:80 \
  ghcr.io/nicolasschutz73/cloudnative-frontend:latest
```

### Image Registry
View published images: [GitHub Packages](https://github.com/NicolasSchutz73?tab=packages&repo_name=CloudNativeApplicationCurse)

## Developement

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
- ✅ **Docker** - Build, test et push des images Docker vers GHCR

**Pipeline Jobs (tous sur self-hosted runner) :**
1. **Lint Job** : Vérifie la qualité du code (frontend + backend)
2. **Build Job** : Compile les applications (frontend + backend)
3. **Test Job** : Exécute les tests unitaires backend
4. **SonarCloud Job** : Analyse de code et Quality Gate
5. **Docker Job** : Build images Docker, healthchecks, et push vers GHCR

**Status checks requis :**
- Tous les jobs CI doivent passer avant merge
- SonarCloud Quality Gate doit être validé
- Branch doit être à jour avec la branche cible

### Pipeline Requirements

**Self-hosted Runner:**
- All jobs run on a self-hosted runner
- Runner must have Docker installed and running
- Required for Docker build and push operations

**Required Secrets:**
- `SONAR_TOKEN` - SonarCloud authentication
- `SONAR_ORGANIZATION` - SonarCloud organization
- `SONAR_PROJECT_KEY` - SonarCloud project key
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions (for GHCR push)

**Docker Job Details:**
```yaml
Jobs:
  1. Build backend Docker image (backend-ci)
  2. Build frontend Docker image (frontend-ci)
  3. Healthcheck - Start and verify containers
  4. Login to GitHub Container Registry
  5. Tag images with commit SHA
  6. Push images to ghcr.io/nicolasschutz73/
```

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.

---

## 📸 TP3 - Docker & CI/CD Screenshots

## TP 3 - Screenshots: 

PART 1 : 
![img.png](img.png)

![img_1.png](img_1.png)

PART 2 :

![img_2.png](img_2.png)

PART 3 : 

![img_3.png](img_3.png)

![img_4.png](img_4.png)

TP 4 : 

## 🔄 Déploiement local automatisé

Le pipeline CI/CD inclut maintenant un job `deploy` exécuté automatiquement sur le runner local après la publication réussie des images Docker sur GHCR.

### Workflow complet

```text
lint -> build -> test -> sonarcloud -> build images -> push registry -> deploy
```

### Fonctionnement du stage `deploy`

Le job `deploy` est déclenché automatiquement uniquement après un `push` sur la branche `main`, lorsque le job `docker` a terminé avec succès.

Le déploiement est piloté par [`scripts/deploy.sh`](scripts/deploy.sh), qui exécute la séquence suivante sur le runner local :

```bash
docker compose down
docker pull ghcr.io/<owner>/cloudnative-backend:$GITHUB_SHA
docker pull ghcr.io/<owner>/cloudnative-frontend:$GITHUB_SHA
docker compose up -d
```

### Garanties d'idempotence

- Le script n'utilise jamais `docker compose down --volumes`.
- Le volume Docker `gym-postgres-data` est conservé entre deux redéploiements.
- Les images backend et frontend sont tirées depuis GHCR avec le tag exact du commit (`github.sha`).
- La relance se fait via `docker compose up -d`, ce qui permet de rejouer le déploiement sans intervention manuelle.

### Pré-requis d'exécution

Le déploiement automatique nécessite :

- un runner GitHub Actions `self-hosted` actif sur la machine locale ;
- Docker et Docker Compose disponibles sur ce runner ;
- les secrets CI configurés, notamment `SONAR_TOKEN`, `SONAR_ORGANIZATION`, `SONAR_PROJECT_KEY` ;
- un accès au registre distant GHCR ;
- une authentification GHCR valide via `GITHUB_TOKEN`.

### Branche active pour le déploiement

- Le déploiement automatique est actif uniquement sur la branche `main`.
- Les `pull_request` sur `main` exécutent les contrôles CI, mais ne publient pas d'image et ne déclenchent pas le déploiement.

### Images utilisées par Docker Compose

`docker-compose.yml` référence désormais les images distantes suivantes :

- `ghcr.io/${GHCR_OWNER}/cloudnative-backend:${IMAGE_TAG}`
- `ghcr.io/${GHCR_OWNER}/cloudnative-frontend:${IMAGE_TAG}`

En CI, `IMAGE_TAG` est positionné automatiquement sur le SHA du commit déployé. En local, la valeur par défaut reste `latest`, et `docker compose up --build` reste utilisable pour le développement.
