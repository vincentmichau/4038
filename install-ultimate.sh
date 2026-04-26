#!/bin/bash

# Night Guards Ultimate Installer v3.0.0
# Installation complète et automatisée

set -e

echo "🚀 Démarrage installation Night Guards Ultimate..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_NAME="nightguards"
NODE_VERSION="18.20.0"
MYSQL_VERSION="8.0"

# Fonctions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Vérification prérequis
check_prerequisites() {
    log_step "Vérification des prérequis..."
    
    # Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js non installé. Installation en cours..."
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        NODE_CURRENT=$(node --version | cut -d'v' -f2)
        log_info "Node.js version: $NODE_CURRENT"
    fi
    
    # NPM
    if ! command -v npm &> /dev/null; then
        log_error "NPM non installé"
        exit 1
    fi
    
    # MySQL
    if ! command -v mysql &> /dev/null; then
        log_warn "MySQL non installé. Installation recommandée pour la production"
        echo "Pour installer MySQL sur Ubuntu/Debian:"
        echo "sudo apt update"
        echo "sudo apt install mysql-server"
        echo "sudo mysql_secure_installation"
    fi
    
    # Git
    if ! command -v git &> /dev/null; then
        log_error "Git non installé"
        sudo apt-get install -y git
    fi
    
    log_info "Prérequis vérifiés ✅"
}

# Installation dépendances
install_dependencies() {
    log_step "Installation des dépendances..."
    
    # Nettoyage cache npm
    npm cache clean --force
    
    # Installation dépendances backend
    log_info "Installation dépendances backend..."
    npm install --production --no-optional
    
    # Installation dépendances frontend
    if [ -d "client" ]; then
        log_info "Installation dépendances frontend..."
        cd client
        npm install --production --no-optional
        cd ..
    fi
    
    log_info "Dépendances installées ✅"
}

# Configuration base de données
setup_database() {
    log_step "Configuration base de données..."
    
    # Demander credentials MySQL
    read -p "Utilisateur MySQL (root): " DB_USER
    DB_USER=${DB_USER:-root}
    read -s -p "Mot de passe MySQL: " DB_PASSWORD
    echo
    
    # Test connexion
    if ! mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" &> /dev/null; then
        log_error "Connexion MySQL échouée"
        exit 1
    fi
    
    # Création base de données
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    # Création utilisateur dédié
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE USER IF NOT EXISTS '${PROJECT_NAME}'@'localhost' IDENTIFIED BY 'SecurePassword123!';"
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON ${PROJECT_NAME}.* TO '${PROJECT_NAME}'@'localhost';"
    mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES;"
    
    log_info "Base de données configurée ✅"
}

# Génération secrets
generate_secrets() {
    log_step "Génération secrets sécurisés..."
    
    JWT_SECRET=$(openssl rand -hex 64)
    SESSION_SECRET=$(openssl rand -hex 64)
    DB_ENCRYPTION_KEY=$(openssl rand -hex 32)
    CHAT_ENCRYPTION_KEY=$(openssl rand -hex 32)
    QR_CODE_SECRET=$(openssl rand -hex 32)
    
    # Création fichier .env
    cat > .env << EOF
# Configuration de la base de données
DB_HOST=localhost
DB_USER=${PROJECT_NAME}
DB_PASSWORD=SecurePassword123!
DB_NAME=${PROJECT_NAME}
DB_PORT=3306
DB_SSL=false

# Configuration JWT
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Configuration serveur
PORT=3000
NODE_ENV=production
API_VERSION=v1

# Configuration email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=noreply@nightguards.com

# Configuration sécurité
BCRYPT_ROUNDS=12
SESSION_SECRET=${SESSION_SECRET}
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Configuration fichiers
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=jpg,jpeg,png,pdf

# Configuration QR Code
QR_CODE_SECRET=${QR_CODE_SECRET}

# Configuration chat
CHAT_ENCRYPTION_KEY=${CHAT_ENCRYPTION_KEY}

# Logging
LOG_LEVEL=info
LOG_FILE=./logs/app.log
EOF
    
    log_info "Secrets générés ✅"
}

# Création répertoires
create_directories() {
    log_step "Création des répertoires..."
    
    DIRS=(
        "uploads"
        "uploads/reports" 
        "uploads/photos"
        "uploads/qr_codes"
        "logs"
        "backups"
        "temp"
        "ssl"
    )
    
    for dir in "${DIRS[@]}"; do
        mkdir -p "$dir"
        chmod 755 "$dir"
    done
    
    log_info "Répertoires créés ✅"
}

# Build frontend
build_frontend() {
    log_step "Build frontend..."
    
    if [ -d "client" ]; then
        cd client
        npm run build
        cd ..
        log_info "Frontend build ✅"
    else
        log_warn "Répertoire client non trouvé"
    fi
}

# Configuration services système
setup_services() {
    log_step "Configuration services système..."
    
    # Création service systemd
    sudo tee /etc/systemd/system/nightguards.service > /dev/null << EOF
[Unit]
Description=Night Guards Service
After=network.target mysql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=$(pwd)
Environment=NODE_ENV=production
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nightguards

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable nightguards
    
    log_info "Services configurés ✅"
}

# Configuration Nginx (optionnel)
setup_nginx() {
    log_step "Configuration Nginx..."
    
    if command -v nginx &> /dev/null; then
        sudo tee /etc/nginx/sites-available/nightguards > /dev/null << EOF
server {
    listen 80;
    server_name _;
    
    # Redirection HTTP vers HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name _;
    
    # Configuration SSL
    ssl_certificate $(pwd)/ssl/cert.pem;
    ssl_certificate_key $(pwd)/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Headers de sécurité
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Frontend statique
    location / {
        root $(pwd)/client/build;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
        
        # Cache statique
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Uploads
    location /uploads/ {
        alias $(pwd)/uploads/;
        expires 1y;
        add_header Cache-Control "public";
    }
}
EOF
        
        sudo ln -sf /etc/nginx/sites-available/nightguards /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx
        log_info "Nginx configuré ✅"
    else
        log_warn "Nginx non installé"
    fi
}

# Configuration monitoring
setup_monitoring() {
    log_step "Configuration monitoring..."
    
    # Installation PM2
    if ! command -v pm2 &> /dev/null; then
        npm install -g pm2
    fi
    
    # Configuration PM2
    cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'nightguards',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production'
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
EOF
    
    # Démarrage avec PM2
    pm2 start ecosystem.config.js
    pm2 save
    pm2 startup
    
    log_info "Monitoring configuré ✅"
}

# Tests finaux
run_tests() {
    log_step "Tests finaux..."
    
    # Test API health
    sleep 5
    if curl -f http://localhost:3000/api/health &> /dev/null; then
        log_info "Test API réussi ✅"
    else
        log_warn "Test API échoué - vérifiez les logs"
    fi
    
    # Test base de données
    if mysql -u"${PROJECT_NAME}" -p"SecurePassword123!" "$PROJECT_NAME" -e "SELECT 1;" &> /dev/null; then
        log_info "Test base de données réussi ✅"
    else
        log_warn "Test base de données échoué"
    fi
}

# Configuration backup
setup_backup() {
    log_step "Configuration backup automatique..."
    
    # Script backup
    cat > backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/var/backups/nightguards"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="nightguards"

# Création répertoire backup
mkdir -p $BACKUP_DIR

# Backup base de données
mysqldump -u nightguards -pSecurePassword123! $DB_NAME > $BACKUP_DIR/db_$DATE.sql

# Backup fichiers
tar -czf $BACKUP_DIR/files_$DATE.tar.gz uploads/ logs/

# Nettoyage anciens backups (7 jours)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup terminé: $DATE"
EOF
    
    chmod +x backup.sh
    
    # Cron quotidien à 2h du matin
    (crontab -l 2>/dev/null; echo "0 2 * * * $(pwd)/backup.sh >> $(pwd)/logs/backup.log 2>&1") | crontab -
    
    log_info "Backup configuré ✅"
}

# Message final
show_success() {
    echo ""
    echo "🎉 INSTALLATION NIGHT GUARDS ULTIMATE TERMINÉE !"
    echo "================================================"
    echo ""
    echo "📋 Informations importantes:"
    echo "   🌐 Application: http://localhost:3000"
    echo "   📊 Monitoring: pm2 monit"
    echo "   📝 Logs: pm2 logs nightguards"
    echo "   🗄️ Base de données: MySQL sur localhost"
    echo "   🔧 Redémarrage: pm2 restart nightguards"
    echo ""
    echo "🔑 Credentials par défaut:"
    echo "   📧 Email: admin@nightguards.com"
    echo "   🔐 Mot de passe: Admin123!"
    echo ""
    echo "⚠️  Actions recommandées:"
    echo "   1. Changer le mot de passe admin"
    echo "   2. Configurer SSL pour la production"
    echo "   3. Configurer les emails SMTP"
    echo "   4. Tester tous les fonctionnalités"
    echo "   5. Configurer les backups externes"
    echo ""
    echo "📚 Documentation: docs/README.md"
    echo "🐛 Support: Créer une issue sur GitHub"
    echo ""
}

# Main execution
main() {
    echo "Installation de Night Guards Ultimate v3.0.0"
    echo "=========================================="
    
    check_prerequisites
    install_dependencies
    setup_database
    generate_secrets
    create_directories
    build_frontend
    setup_services
    setup_nginx
    setup_monitoring
    setup_backup
    run_tests
    show_success
    
    echo "✨ Night Guards est maintenant prêt !"
}

# Exécution
main "$@"
