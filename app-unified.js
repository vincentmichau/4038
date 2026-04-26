/**
 * NIGHT GUARDS SYSTEM - VERSION UNIFIÉE
 * Application One-Shot - Déploiement Simplifié et Robuste
 * 
 * Cette version fusionne toutes les fonctionnalités en une seule application
 * pour un déploiement rapide et une maintenance simplifiée.
 */

const express = require('express');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');
const dotenv = require('dotenv');

// Importation des modules unifiés
const UnifiedService = require('./services/unifiedService');
const unifiedRoutes = require('./routes/unifiedRoutes');

// Configuration des variables d'environnement
dotenv.config();

// =============================================
// APPLICATION EXPRESS
// =============================================

const app = express();

// Configuration
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Middlewares globaux
app.use(compression()); // Compression des réponses
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:3001'],
  credentials: true
}));

// Logging
if (NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Parsing JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// =============================================
// ROUTES
// =============================================

// Route racine
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Night Guards System - API Unifiée',
    version: '2.0.0',
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      auth: '/auth/login',
      reporting: '/reporting/create',
      tickets: '/tickets/create',
      verification: '/verify/:hash'
    }
  });
});

// Routes de l'API unifiée
app.use('/api', unifiedRoutes);

// =============================================
// GESTION DES ERREURS
// =============================================

// Middleware de gestion des erreurs asynchrones
app.use((error, req, res, next) => {
  console.error('Erreur non gérée:', error);
  
  // Erreur de Multer (upload)
  if (error.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      error: 'Fichier trop volumineux (max 10MB)'
    });
  }
  
  if (error.code === 'LIMIT_FILE_COUNT') {
    return res.status(413).json({
      success: false,
      error: 'Trop de fichiers'
    });
  }
  
  // Erreur de validation Multer
  if (error.message.includes('non autorisé')) {
    return res.status(400).json({
      success: false,
      error: error.message
    });
  }
  
  // Erreur générale
  res.status(500).json({
    success: false,
    error: NODE_ENV === 'development' ? error.message : 'Erreur serveur interne'
  });
});

// =============================================
// DÉMARRAGE DU SERVEUR
// =============================================

async function startServer() {
  try {
    console.log('🚀 Démarrage de Night Guards System v2.0.0...');
    
    // Initialisation du service unifié
    await UnifiedService.initialize();
    
    // Démarrage du serveur
    const server = app.listen(PORT, () => {
      console.log(`✅ Serveur démarré sur le port ${PORT}`);
      console.log(`🌍 Environnement: ${NODE_ENV}`);
      console.log(`📊 Health Check: http://localhost:${PORT}/health`);
      console.log(`📖 API Documentation: http://localhost:${PORT}/`);
      
      if (NODE_ENV === 'development') {
        console.log(`🧪 Mode développement activé`);
        console.log(`🔄 Routes de test disponibles`);
      }
    });
    
    // Gestion gracieuse de l'arrêt
    const gracefulShutdown = (signal) => {
      console.log(`\n📡 Signal ${signal} reçu, arrêt gracieux...`);
      
      server.close(() => {
        console.log('✅ Serveur arrêté avec succès');
        process.exit(0);
      });
      
      // Forcer l'arrêt après 10 secondes
      setTimeout(() => {
        console.log('⏰ Timeout forcé, arrêt immédiat');
        process.exit(1);
      }, 10000);
    };
    
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
    // Gestion des erreurs non capturées
    process.on('uncaughtException', (error) => {
      console.error('❌ Erreur non capturée:', error);
      gracefulShutdown('uncaughtException');
    });
    
    process.on('unhandledRejection', (reason, promise) => {
      console.error('❌ Rejet non géré:', reason);
      console.error('Promise:', promise);
      gracefulShutdown('unhandledRejection');
    });
    
    return server;
    
  } catch (error) {
    console.error('❌ Erreur lors du démarrage:', error);
    process.exit(1);
  }
}

// =============================================
// VÉRIFICATION DES DÉPENDANCES
// =============================================

function checkDependencies() {
  const requiredPackages = [
    'express',
    'mysql2',
    'puppeteer',
    'qrcode',
    'nodemailer',
    'multer',
    'helmet',
    'express-rate-limit',
    'compression',
    'cors',
    'morgan',
    'dotenv',
    'crypto',
    'fs',
    'path',
    'node-cron'
  ];
  
  const missingPackages = [];
  
  for (const pkg of requiredPackages) {
    try {
      require.resolve(pkg);
    } catch (error) {
      missingPackages.push(pkg);
    }
  }
  
  if (missingPackages.length > 0) {
    console.error('❌ Packages manquants:', missingPackages.join(', '));
    console.error('Veuillez installer les packages manquants avec:');
    console.error(`npm install ${missingPackages.join(' ')}`);
    process.exit(1);
  }
}

// =============================================
// VÉRIFICATION DE LA BASE DE DONNÉES
// =============================================

async function checkDatabase() {
  try {
    const database = require('./config/database');
    
    // Test de connexion
    await database.query('SELECT 1');
    console.log('✅ Connexion à la base de données réussie');
    
    // Vérification des tables principales
    const [tables] = await database.query('SHOW TABLES');
    const tableNames = tables.map(row => Object.values(row)[0]);
    
    const requiredTables = [
      'users',
      'clients',
      'sites',
      'reportings',
      'tickets',
      'user_sessions',
      'security_logs'
    ];
    
    const missingTables = requiredTables.filter(table => !tableNames.includes(table));
    
    if (missingTables.length > 0) {
      console.warn('⚠️ Tables manquantes:', missingTables.join(', '));
      console.warn('Veuillez exécuter le schéma de base de données:');
      console.warn('mysql -u username -p database_name < database/complete-schema.sql');
    } else {
      console.log('✅ Base de données vérifiée');
    }
    
  } catch (error) {
    console.error('❌ Erreur de connexion à la base de données:', error.message);
    console.error('Veuillez vérifier votre configuration dans .env');
    process.exit(1);
  }
}

// =============================================
// VÉRIFICATION DES VARIABLES D'ENVIRONNEMENT
// =============================================

function checkEnvironment() {
  const requiredEnvVars = [
    'DB_HOST',
    'DB_USER',
    'DB_PASSWORD',
    'DB_NAME'
  ];
  
  const optionalEnvVars = [
    'JWT_SECRET',
    'QR_CODE_SECRET',
    'SMTP_HOST',
    'SMTP_USER',
    'SMTP_PASS',
    'EMAIL_FROM',
    'NODE_ENV'
  ];
  
  const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
  
  if (missingVars.length > 0) {
    console.error('❌ Variables d\'environnement requises manquantes:', missingVars.join(', '));
    console.error('Veuillez configurer ces variables dans votre fichier .env');
    process.exit(1);
  }
  
  const missingOptional = optionalEnvVars.filter(varName => !process.env[varName]);
  
  if (missingOptional.length > 0) {
    console.warn('⚠️ Variables d\'environnement optionnelles manquantes:', missingOptional.join(', '));
    console.warn('Certaines fonctionnalités pourraient ne pas être disponibles');
  }
  
  console.log('✅ Variables d\'environnement vérifiées');
}

// =============================================
// DÉMARRAGE
// =============================================

// Vérifications pré-démarrage
console.log('🔍 Vérifications pré-démarrage...');

checkDependencies();
checkEnvironment();
await checkDatabase();

// Démarrage du serveur
startServer().catch(error => {
  console.error('❌ Erreur fatale au démarrage:', error);
  process.exit(1);
});

// Export pour les tests
module.exports = app;
