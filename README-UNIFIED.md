# Night Guards System - Version Unifiée v2.0.0

🚀 **Version One-Shot - Déploiement Simplifié et Robuste**

Cette version fusionnée intègre toutes les fonctionnalités du système Night Guards en une application unifiée pour un déploiement rapide et une maintenance simplifiée.

## 🎯 Fonctionnalités Intégrées

### 📋 **Gestion des Rapports de Veille**
- Création et gestion des rapports de nuit
- Génération PDF avec QR code et signature numérique
- Envoi automatique par email avec destinataires dynamiques
- Authentification et infalsifiabilité des documents

### 🎫 **Système de Tickets (Plaintes Clients)**
- Création et suivi des tickets
- Classification par catégorie, priorité et statut
- Système d'escalade à plusieurs niveaux
- Solutions et mesures préventives
- Historique complet et journalisation

### 🔐 **Sécurité Maximale**
- Authentification avec sessions sécurisées
- Validation des entrées et protection XSS
- Rate limiting et détection d'anomalies
- Journalisation complète des événements
- Signatures numériques HMAC-SHA256

### 📊 **Rapports et Statistiques**
- PDF professionnels et authentifiés
- Tableaux de bord et statistiques
- Export et analyse des données
- Monitoring et santé du système

## 🚀 Déploiement Rapide

### Prérequis
- Node.js >= 16.0.0
- MySQL >= 8.0
- npm >= 8.0.0

### Installation One-Shot

```bash
# 1. Clone et configuration
git clone <repository-url>
cd night-guards
cp .env.example .env

# 2. Installation des dépendances
npm install

# 3. Configuration de la base de données
# Éditez .env avec vos informations MySQL

# 4. Initialisation de la base de données
mysql -u username -p database_name < database/complete-schema.sql

# 5. Démarrage de l'application
npm start
```

### Avec Docker (Recommandé)

```bash
# 1. Configuration
cp .env.example .env
# Éditez .env avec vos configurations

# 2. Déploiement complet
docker-compose -f docker-compose-unified.yml up -d

# 3. Vérification
curl http://localhost:3000/health
```

## ⚙️ Configuration

### Variables d'Environnement

```bash
# Base de données
DB_HOST=localhost
DB_USER=nightguards
DB_PASSWORD=secure_password_2024
DB_NAME=nightguards_db

# Sécurité
JWT_SECRET=your-super-secret-jwt-key-2024
QR_CODE_SECRET=your-super-secret-qr-key-2024

# Email (optionnel)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=noreply@nightguards.com

# Application
NODE_ENV=production
PORT=3000
```

## 📚 Documentation API

### Endpoints Principaux

#### Authentification
```http
POST /api/auth/login
POST /api/auth/logout
```

#### Rapports de Veille
```http
POST /api/reporting/create
GET /api/reporting/list
POST /api/reporting/:reportId/pdf
POST /api/reporting/:reportId/send
```

#### Tickets
```http
POST /api/tickets/create
GET /api/tickets/list
```

#### Système
```http
GET /api/health
GET /api/stats
GET /api/verify/:hash
```

### Exemple d'utilisation

```javascript
// Authentification
const loginResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});

const { sessionToken } = await loginResponse.json();

// Création d'un rapport
const reportResponse = await fetch('/api/reporting/create', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${sessionToken}`
  },
  body: JSON.stringify({
    siteId: 1,
    date: '2024-01-15',
    title: 'Rapport de veille',
    content: 'Patrouille effectuée sans incident.',
    incidents: [],
    observations: [],
    tasksCompleted: []
  })
});
```

## 🛡️ Sécurité

### Mesures Implémentées
- **Authentification** avec tokens JWT et sessions
- **Validation** des entrées contre XSS et injections
- **Rate Limiting** pour prévenir les abus
- **Détection** d'anomalies et comportements suspects
- **Journalisation** complète des événements de sécurité
- **Signatures** numériques pour l'intégrité des documents
- **HTTPS** obligatoire en production

### Bonnes Pratiques
- Utiliser des mots de passe forts
- Changer régulièrement les secrets
- Surveiller les logs de sécurité
- Maintenir les dépendances à jour
- Effectuer des sauvegardes régulières

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:3000/health
```

### Statistiques
```bash
curl -H "Authorization: Bearer <token>" \
     http://localhost:3000/api/stats
```

### Logs
- Application: `logs/app.log`
- Erreurs: `logs/error.log`
- Sécurité: Base de données `security_logs`

## 🔧 Maintenance

### Scripts Utiles

```bash
# Sauvegarde de la base de données
npm run backup

# Vérification de santé
npm run health

# Analyse de sécurité
npm run security-check

# Tests de performance
npm run performance-test

# Nettoyage des logs
npm run cleanup
```

### Mises à Jour

1. **Sauvegarde** des données
2. **Arrêt** de l'application
3. **Mise à jour** du code
4. **Migration** de la base de données
5. **Redémarrage** de l'application

## 🐛 Dépannage

### Problèmes Communs

#### Erreur de connexion à la base de données
```bash
# Vérifier les variables d'environnement
echo $DB_HOST $DB_USER $DB_NAME

# Tester la connexion MySQL
mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME
```

#### Erreur de génération PDF
```bash
# Vérifier l'installation de Puppeteer
npm list puppeteer

# Permissions des répertoires
ls -la reports/ uploads/
```

#### Performance lente
```bash
# Monitoring des ressources
docker stats

# Analyse des requêtes SQL
SHOW PROCESSLIST;
```

### Support

- **Documentation**: `/docs`
- **Tests**: `/tests`
- **Logs**: `/logs`
- **Issues**: GitHub Repository

## 📈 Scalabilité

### Options de Scalabilité
- **Horizontal**: Load balancer + multiples instances
- **Vertical**: Augmentation des ressources serveur
- **Database**: MySQL Cluster ou réplication
- **Cache**: Redis pour les sessions et données temporaires
- **CDN**: Pour les fichiers statiques et rapports

### Performance
- **Compression** activée (gzip)
- **Cache** des réponses statiques
- **Connection pooling** pour la base de données
- **Async/await** pour les opérations I/O

## 📝 Développement

### Structure du Projet

```
night-guards/
├── app-unified.js          # Application principale
├── services/
│   └── unifiedService.js   # Logique métier unifiée
├── controllers/
│   └── unifiedController.js # Contrôleurs API
├── routes/
│   └── unifiedRoutes.js    # Routes API
├── database/
│   └── complete-schema.sql # Schéma de base de données
├── config/                 # Fichiers de configuration
├── reports/               # Rapports générés
├── uploads/               # Fichiers uploadés
├── logs/                  # Logs de l'application
├── tests/                 # Tests unitaires
└── docs/                  # Documentation
```

### Contribution

1. Fork du projet
2. Branche de fonctionnalité
3. Tests et documentation
4. Pull request

## 📄 Licence

MIT License - Voir le fichier `LICENSE` pour plus de détails.

---

**Night Guards System v2.0.0** - Sécurité, Fiabilité, Performance

*Pour le support technique: support@nightguards.com*
