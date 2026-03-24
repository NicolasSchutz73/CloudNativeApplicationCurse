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

## Monitoring & Observability

### Fichiers ajoutés

- `docker-compose.monitoring.yml`
- `MONITORING.md`
- `monitoring/prometheus/prometheus.yml`
- `monitoring/promtail/promtail-config.yml`
- `monitoring/loki/loki-config.yaml`
- `monitoring/grafana/provisioning/...`
- `monitoring/grafana/dashboards/...`

### Variables nécessaires

Ajoutez dans `.env` :

```bash
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=change-me
```

### Lancement de la stack blue/green

```bash
docker network create gym-bluegreen-network || true
docker volume create gym-postgres-data || true
docker compose -f docker-compose.base.yml up -d
docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d
```

Le reverse proxy expose maintenant `/metrics` et redirige cette route vers le backend actif.

### Lancement de la stack monitoring

```bash
docker compose --env-file .env -f docker-compose.monitoring.yml up -d
```

### Accès aux services

- Grafana : http://localhost:3000
- Prometheus : http://localhost:9090
- cAdvisor : http://localhost:8081
- Endpoint backend métriques via proxy : http://localhost/metrics

### Vérifications attendues pour le TP

```bash
# Cibles Prometheus
curl http://localhost:9090/api/v1/targets

# Métriques backend
curl http://localhost/metrics

# Logs backend dans Loki via Grafana Explore
docker logs monitoring-promtail
```

### Dashboards provisionnés

- `TP6 - Backend Metrics`
- `TP6 - Logs & Correlation`

Ils sont chargés automatiquement au démarrage de Grafana.

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

## 🔵🟢 Déploiement blue/green

Le pipeline CI/CD inclut maintenant un job `blue-green-deploy` execute automatiquement sur le runner local apres la publication reussie des images Docker sur GHCR.

### Workflow complet

```text
lint -> build -> test -> sonarcloud -> build images -> push registry -> blue-green-deploy
```

### Architecture

```text
[Client] -> [Reverse Proxy Nginx] -> [Blue frontend/backend]
                                 \-> [Green frontend/backend]
```

- `blue` = couleur actuellement exposee par le proxy
- `green` = couleur candidate a deployer, ou l'inverse
- Postgres reste unique et partage par les deux couleurs

### Fichiers Docker Compose

- `docker-compose.base.yml` : Postgres + reverse proxy
- `docker-compose.blue.yml` : `frontend-blue` + `backend-blue`
- `docker-compose.green.yml` : `frontend-green` + `backend-green`
- `docker-compose.yml` : stack locale simple conservee pour le developpement classique

Commandes utiles :

```bash
docker compose -f docker-compose.base.yml up -d
docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d
docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d
```

### Fonctionnement du stage `blue-green-deploy`

Le stage est execute uniquement apres un `push` sur la branche `main`.

Le script [`scripts/blue-green-deploy.sh`](scripts/blue-green-deploy.sh) :

1. lit la couleur active dans `proxy/state/active_color`
2. choisit la couleur inactive
3. tire les images GHCR backend et frontend taguees avec `github.sha`
4. deploye uniquement la couleur inactive
5. attend les healthchecks
6. met a jour `proxy/upstreams/active-upstream.conf`
7. recharge Nginx avec `nginx -s reload`
8. laisse l'ancienne couleur demarree pour un rollback quasi instantane

### Reverse proxy

Le reverse proxy recoit le trafic sur :

- [http://localhost](http://localhost)

Il route :

- `/` vers le frontend actif
- `/api` vers le backend actif
- `/health` vers le backend actif

La couleur active est stockee dans :

- `proxy/state/active_color`

La cible Nginx active est definie dans :

- `proxy/upstreams/active-upstream.conf`

### Rollback

Le rollback ne redeploie pas l'ancienne version si elle est toujours demarree. Il suffit de rebascule le proxy :

```bash
./scripts/rollback.sh blue
./scripts/rollback.sh green
```

### Conditions d'execution

- Le blue/green automatique est actif uniquement sur `main`
- Les `pull_request` sur `main` executent les controles CI, mais pas le deploiement
- Le runner GitHub Actions `self-hosted` doit etre actif
- Docker Desktop doit etre demarre sur la machine locale
- Les secrets SonarCloud et l'acces GHCR doivent etre valides

### Debug

```bash
docker compose -f docker-compose.base.yml ps
docker compose -f docker-compose.base.yml -f docker-compose.blue.yml ps
docker compose -f docker-compose.base.yml -f docker-compose.green.yml ps
cat proxy/state/active_color
docker logs reverse-proxy
```

TP 6 : 

![tp6-backend-metrics-endpoint.png](tp6-backend-metrics-endpoint.png)
![tp6-grafana-backend-metrics.png](tp6-grafana-backend-metrics.png)
![tp6-grafana-logs-correlation.png](tp6-grafana-logs-correlation.png)
![tp6-prometheus-targets.png](tp6-prometheus-targets.png)