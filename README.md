# 🌙 Night Guards System

Système complet de reporting pour veilleurs de nuit avec interface web, mobile et API REST.

## 📋 Description

Night Guards System est une application complète conçue pour les agences de sécurité et les entreprises employant des veilleurs de nuit. Elle permet de gérer les plannings, créer des rapports détaillés avec photos, communiquer via un chat crypté, et générer des PDF sécurisés avec QR codes.

## ✨ Fonctionnalités

### 🔐 Sécurité & Authentification
- Authentification JWT sécurisée avec rafraîchissement automatique
- Chiffrement AES-256 des données sensibles
- Protection contre les attaques CSRF, XSS, injection SQL
- Rate limiting et protection contre les tentatives de connexion
- Conformité RGPD avec gestion des données personnelles

### 📅 Planning & Gestion
- Calendrier interactif avec drag & drop
- Gestion des gardes et plannings
- Import depuis les systèmes RH (Combo, etc.)
- Export iCal pour synchronisation
- Notifications automatiques de début/fin de garde

### 📋 Reporting Avancé
- Création de rapports détaillés avec photos
- Gestion des incidents et observations
- Checklist des tâches personnalisables
- Statuts: brouillon, validé, envoyé
- Génération PDF avec QR code de sécurité

### 💬 Communication
- Chat crypté de bout en bout
- Notifications push, email et SMS
- Gestion des conversations et messages lus
- Indicateurs de présence en temps réel

### 📊 Administration
- Dashboard avec statistiques en temps réel
- Gestion des utilisateurs, sites et clients
- Configuration système et paramètres
- Export de données et sauvegardes
- Logs et monitoring

## 🏗️ Architecture

L'application est disponible en 3 versions:

1. **Node.js/Express/React** - Version principale avec interface moderne
2. **React Native** - Application mobile Android/iOS
3. **PHP/MySQL/Bootstrap** - Version légère pour hébergement simple

## 🚀 Installation

### Prérequis

- Node.js 18+ (pour la version Node.js)
- PHP 8.1+ (pour la version PHP)
- MySQL 8.0+ ou MariaDB 10.5+
- Composer (pour la version PHP)
- React Native CLI (pour la version mobile)

### Installation Version Node.js

```bash
# Cloner le projet
git clone <repository-url>
cd nightguards

# Installer les dépendances
npm install

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos configurations

# Créer la base de données
mysql -u root -p < database/schema.sql

# Démarrer le serveur
npm start
```

### Installation Version PHP

```bash
# Aller dans le dossier PHP
cd php

# Installer les dépendances
composer install

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos configurations

# Démarrer le serveur
composer start
```

### Installation Version Mobile

```bash
# Aller dans le dossier mobile
cd mobile

# Installer les dépendances
npm install

# Pour Android
npm run android

# Pour iOS
npm run ios
```

## 📖 Documentation

### Documentation Utilisateur
- [Guide d'installation](docs/installation.md)
- [Guide utilisateur](docs/user-guide.md)
- [Guide administrateur](docs/admin-guide.md)
- [FAQ](docs/faq.md)

### Documentation Technique
- [API Reference](docs/api-reference.md)
- [Architecture](docs/architecture.md)
- [Base de données](docs/database.md)
- [Sécurité](docs/security.md)

### Documentation Développeur
- [Contribuer](docs/contributing.md)
- [Déploiement](docs/deployment.md)
- [Tests](docs/testing.md)
- [Debug](docs/debug.md)

## 🔧 Configuration

### Variables d'environnement principales

```bash
# Base de données
DB_HOST=localhost
DB_DATABASE=nightguards
DB_USERNAME=root
DB_PASSWORD=votre_mot_de_passe

# JWT
JWT_SECRET=votre_clé_secrète_jwt
JWT_EXPIRE_IN=24h

# Email
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=votre_email@gmail.com
MAIL_PASSWORD=votre_mot_de_passe_app

# Sécurité
ENCRYPTION_KEY=votre_clé_de_chiffrement_32_caractères
```

## 📱 Utilisation

### Connexion
1. Accéder à l'application via votre navigateur
2. Créer un compte administrateur ou se connecter
3. Configurer les sites et utilisateurs

### Création d'un rapport
1. Aller dans la section "Reporting"
2. Cliquer sur "Nouveau rapport"
3. Remplir les informations du site
4. Ajouter les incidents, observations et photos
5. Valider et envoyer le rapport

### Gestion du planning
1. Aller dans la section "Planning"
2. Cliquer sur le calendrier pour ajouter une garde
3. Sélectionner le site, le veilleur et les horaires
4. Synchroniser avec les systèmes RH si nécessaire

## 🔒 Sécurité

L'application inclut de multiples mesures de sécurité:

- **Authentification**: Tokens JWT avec expiration
- **Chiffrement**: AES-256 pour les données sensibles
- **Validation**: Input sanitization et validation
- **Rate Limiting**: Protection contre les attaques par force brute
- **CSRF**: Protection contre les requêtes cross-site
- **XSS**: Protection contre les injections de code
- **SQL Injection**: Utilisation de requêtes préparées

## 📊 Statistiques & Monitoring

- Tableau de bord avec métriques en temps réel
- Graphiques sur les rapports et gardes
- Monitoring des performances système
- Logs détaillés avec niveaux de sévérité
- Alertes automatiques sur les anomalies

## 🔄 Synchronisation & Hors-ligne

- Mode hors-ligne pour l'application mobile
- Synchronisation automatique lors de la reconnexion
- Cache intelligent pour les performances
- Gestion des conflits de synchronisation

## 🌐 Multi-plateforme

### Web
- Navigateurs modernes (Chrome, Firefox, Safari, Edge)
- Responsive design pour mobile et desktop
- PWA (Progressive Web App) support

### Mobile
- Android 8.0+ (API 26+)
- iOS 13.0+
- Notifications push natives
- Camera et stockage local

### API
- RESTful API complète
- Documentation OpenAPI/Swagger
- Rate limiting par endpoint
- Support CORS

## 🧪 Tests

```bash
# Tests unitaires
npm test

# Tests d'intégration
npm run test:integration

# Tests E2E
npm run test:e2e

# Tests de sécurité
npm run test:security
```

## 📦 Déploiement

### Production (Node.js)
```bash
# Build
npm run build

# Démarrer en production
npm start:prod
```

### Docker
```bash
# Build image
docker build -t nightguards .

# Run container
docker run -p 3000:3000 nightguards
```

### Heroku
```bash
# Deploy
git push heroku main
```

## 🤝 Contribuer

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amazing-feature`)
3. Commit les changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir un Pull Request

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🆘 Support

- 📧 Email: support@nightguards.com
- 💬 Discord: [Serveur Discord](https://discord.gg/nightguards)
- 📖 Documentation: [docs.nightguards.com](https://docs.nightguards.com)
- 🐛 Issues: [GitHub Issues](https://github.com/nightguards/system/issues)

## 🙏 Remerciements

- L'équipe de développement
- Les beta-testeurs
- La communauté open-source
- Nos clients et partenaires

---

**Night Guards System** © 2024 - Tous droits réservés
