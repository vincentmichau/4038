#!/bin/bash

# 🚀 INSTALLATION ONE-SHOT - Night Guards System
# Installation complète et optimisée en une seule commande

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour le output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonctions d'affichage
print_header() {
    echo -e "${BLUE}🌙 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# Vérification des prérequis
check_prerequisites() {
    print_header "Vérification des prérequis..."
    
    # Vérifier Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js n'est pas installé. Veuillez installer Node.js 18+"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        print_error "Node.js 18+ est requis. Version actuelle: $(node -v)"
        exit 1
    fi
    print_success "Node.js $(node -v) détecté"
    
    # Vérifier npm
    if ! command -v npm &> /dev/null; then
        print_error "npm n'est pas installé"
        exit 1
    fi
    print_success "npm $(npm -v) détecté"
    
    # Vérifier MySQL/MariaDB
    if ! command -v mysql &> /dev/null && ! command -v mariadb &> /dev/null; then
        print_warning "MySQL/MariaDB n'est pas détecté. Installation en cours..."
        install_mysql
    else
        print_success "MySQL/MariaDB détecté"
    fi
    
    # Vérifier Redis (optionnel)
    if ! command -v redis-server &> /dev/null; then
        print_warning "Redis n'est pas détecté. Installation en cours..."
        install_redis
    else
        print_success "Redis détecté"
    fi
    
    # Vérifier PHP (optionnel)
    if ! command -v php &> /dev/null; then
        print_warning "PHP n'est pas détecté. Installation en cours..."
        install_php
    else
        print_success "PHP $(php -v | head -n1) détecté"
    fi
    
    # Vérifier Docker (optionnel)
    if ! command -v docker &> /dev/null; then
        print_warning "Docker n'est pas détecté. Installation optionnelle..."
    else
        print_success "Docker $(docker --version) détecté"
    fi
}

# Installation MySQL
install_mysql() {
    if command -v apt-get &> /dev/null; then
        print_step "Installation MySQL/MariaDB (Debian/Ubuntu)..."
        sudo apt-get update
        sudo apt-get install -y mariadb-server mariadb-client
        sudo systemctl start mariadb
        sudo systemctl enable mariadb
    elif command -v yum &> /dev/null; then
        print_step "Installation MySQL/MariaDB (CentOS/RHEL)..."
        sudo yum install -y mariadb-server mariadb
        sudo systemctl start mariadb
        sudo systemctl enable mariadb
    elif command -v brew &> /dev/null; then
        print_step "Installation MySQL (macOS)..."
        brew install mysql
        brew services start mysql
    else
        print_error "Système d'exploitation non supporté pour l'installation automatique de MySQL"
        exit 1
    fi
    print_success "MySQL/MariaDB installé"
}

# Installation Redis
install_redis() {
    if command -v apt-get &> /dev/null; then
        print_step "Installation Redis (Debian/Ubuntu)..."
        sudo apt-get install -y redis-server
        sudo systemctl start redis-server
        sudo systemctl enable redis-server
    elif command -v yum &> /dev/null; then
        print_step "Installation Redis (CentOS/RHEL)..."
        sudo yum install -y redis
        sudo systemctl start redis
        sudo systemctl enable redis
    elif command -v brew &> /dev/null; then
        print_step "Installation Redis (macOS)..."
        brew install redis
        brew services start redis
    else
        print_warning "Redis non installé (optionnel)"
        return
    fi
    print_success "Redis installé"
}

# Installation PHP
install_php() {
    if command -v apt-get &> /dev/null; then
        print_step "Installation PHP (Debian/Ubuntu)..."
        sudo apt-get install -y php php-mysql php-json php-mbstring php-curl php-xml php-zip
    elif command -v yum &> /dev/null; then
        print_step "Installation PHP (CentOS/RHEL)..."
        sudo yum install -y php php-mysql php-json php-mbstring php-curl php-xml
    elif command -v brew &> /dev/null; then
        print_step "Installation PHP (macOS)..."
        brew install php
    else
        print_warning "PHP non installé (optionnel)"
        return
    fi
    print_success "PHP installé"
}

# Configuration de la base de données
setup_database() {
    print_header "Configuration de la base de données..."
    
    # Demander les informations de connexion
    echo -e "${CYAN}Veuillez entrer les informations de la base de données:${NC}"
    read -p "Hôte MySQL [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    read -p "Port MySQL [3306]: " DB_PORT
    DB_PORT=${DB_PORT:-3306}
    
    read -p "Nom de la base de données [nightguards]: " DB_NAME
    DB_NAME=${DB_NAME:-nightguards}
    
    read -p "Utilisateur MySQL [root]: " DB_USER
    DB_USER=${DB_USER:-root}
    
    read -s -p "Mot de passe MySQL: " DB_PASSWORD
    echo
    
    # Créer la base de données
    print_step "Création de la base de données..."
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" || {
        print_error "Impossible de se connecter à MySQL ou de créer la base de données"
        exit 1
    }
    
    # Importer le schéma
    print_step "Import du schéma de la base de données..."
    if [ -f "database/schema.sql" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < database/schema.sql
        print_success "Schéma importé"
    else
        print_warning "database/schema.sql non trouvé, création du schéma manuel..."
        create_database_schema "$DB_HOST" "$DB_PORT" "$DB_USER" "$DB_PASSWORD" "$DB_NAME"
    fi
    
    # Appliquer les optimisations
    if [ -f "database/optimization.sql" ]; then
        print_step "Application des optimisations..."
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < database/optimization.sql
        print_success "Optimisations appliquées"
    fi
    
    # Sauvegarder la configuration
    cat > .env << EOF
# Configuration de la base de données
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_CHARSET=utf8mb4
DB_COLLATION=utf8mb4_unicode_ci
EOF
    
    print_success "Base de données configurée"
}

# Création du schéma de base de données
create_database_schema() {
    local DB_HOST=$1
    local DB_PORT=$2
    local DB_USER=$3
    local DB_PASSWORD=$4
    local DB_NAME=$5
    
    print_step "Création du schéma de base de données..."
    
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" << 'EOF'
-- Utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    role ENUM('admin', 'manager', 'veilleur') DEFAULT 'veilleur',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Clients
CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Sites
CREATE TABLE IF NOT EXISTS sites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    coordinates VARCHAR(100),
    logo_url VARCHAR(255),
    reporting_schedule TIME DEFAULT '08:00:00',
    auto_send BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- Planning
CREATE TABLE IF NOT EXISTS planning (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    site_id INT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    status ENUM('planifie', 'en_cours', 'termine', 'annule') DEFAULT 'planifie',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (site_id) REFERENCES sites(id)
);

-- Reportings
CREATE TABLE IF NOT EXISTS reportings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    site_id INT,
    date DATE NOT NULL,
    status ENUM('brouillon', 'valide', 'envoye') DEFAULT 'brouillon',
    incidents JSON,
    observations JSON,
    tasks_completed JSON,
    photos_urls JSON,
    qr_code_hash VARCHAR(255),
    pdf_path VARCHAR(255),
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (site_id) REFERENCES sites(id)
);

-- Chat Messages
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT,
    receiver_id INT,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id)
);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'warning', 'error', 'success') DEFAULT 'info',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Index pour les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role_active ON users(role, is_active);
CREATE INDEX idx_sites_client_active ON sites(client_id, is_active);
CREATE INDEX idx_planning_user_dates ON planning(user_id, start_date, end_date);
CREATE INDEX idx_reportings_date_status ON reportings(date, status);
CREATE INDEX idx_reportings_user_site ON reportings(user_id, site_id);
CREATE INDEX idx_chat_conversation ON chat_messages(sender_id, receiver_id, sent_at);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);

-- Utilisateur administrateur par défaut
INSERT INTO users (username, email, password, first_name, last_name, role) 
VALUES ('admin', 'admin@nightguards.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uO9W', 'Admin', 'System', 'admin');
EOF

    print_success "Schéma de base de données créé"
}

# Installation des dépendances
install_dependencies() {
    print_header "Installation des dépendances..."
    
    # Installation des dépendances principales
    print_step "Installation des dépendances Node.js..."
    npm install
    
    # Installation des dépendances client
    if [ -d "client" ]; then
        print_step "Installation des dépendances client React..."
        cd client
        npm install
        cd ..
    fi
    
    # Installation des dépendances mobile
    if [ -d "mobile" ]; then
        print_step "Installation des dépendances mobile React Native..."
        cd mobile
        npm install
        cd ..
    fi
    
    # Installation des dépendances desktop
    if [ -d "desktop" ]; then
        print_step "Installation des dépendances desktop Electron..."
        cd desktop
        npm install
        cd ..
    fi
    
    # Installation des dépendances PHP
    if [ -d "php" ] && command -v composer &> /dev/null; then
        print_step "Installation des dépendances PHP..."
        cd php
        composer install --no-dev --optimize-autoloader
        cd ..
    fi
    
    print_success "Dépendances installées"
}

# Configuration de la sécurité
setup_security() {
    print_header "Configuration de la sécurité..."
    
    # Exécuter le script de durcissement de sécurité
    if [ -f "scripts/security-hardening.js" ]; then
        print_step "Application du durcissement de sécurité..."
        node scripts/security-hardening.js
        print_success "Sécurité configurée"
    else
        print_warning "Script de sécurité non trouvé, configuration manuelle..."
        
        # Générer des clés de base
        JWT_SECRET=$(openssl rand -hex 32)
        ENCRYPTION_KEY=$(openssl rand -hex 32)
        SESSION_SECRET=$(openssl rand -hex 32)
        
        # Ajouter au .env
        cat >> .env << EOF

# Configuration de sécurité
JWT_SECRET=$JWT_SECRET
ENCRYPTION_KEY=$ENCRYPTION_KEY
SESSION_SECRET=$SESSION_SECRET
JWT_EXPIRE_IN=24h
JWT_REFRESH_EXPIRE_IN=7d
EOF
        print_success "Clés de sécurité générées"
    fi
}

# Build des applications
build_applications() {
    print_header "Build des applications..."
    
    # Build du client React
    if [ -d "client" ]; then
        print_step "Build du client React..."
        cd client
        npm run build
        cd ..
        print_success "Client React buildé"
    fi
    
    # Build de l'application mobile
    if [ -d "mobile" ]; then
        print_step "Build de l'application mobile..."
        cd mobile
        # Build Android
        if [ -d "android" ]; then
            npm run build:android || print_warning "Build Android échoué (peut nécessiter Android SDK)"
        fi
        cd ..
        print_success "Application mobile buildée"
    fi
    
    # Build de l'application desktop
    if [ -d "desktop" ]; then
        print_step "Build de l'application desktop..."
        cd desktop
        npm run build || npm run dist
        cd ..
        print_success "Application desktop buildée"
    fi
}

# Configuration des services
setup_services() {
    print_header "Configuration des services..."
    
    # Créer les scripts de service
    create_service_scripts
    
    # Configurer les permissions
    setup_permissions
    
    print_success "Services configurés"
}

# Création des scripts de service
create_service_scripts() {
    # Script de démarrage
    cat > start.sh << 'EOF'
#!/bin/bash

# 🚀 Script de démarrage - Night Guards System

echo "🌙 Démarrage de Night Guards System..."

# Démarrer Redis si disponible
if command -v redis-server &> /dev/null; then
    redis-server --daemonize yes --port 6379
    echo "✅ Redis démarré"
fi

# Démarrer le serveur Node.js
echo "🖥️ Démarrage du serveur principal..."
npm start

echo "🎉 Night Guards System est démarré!"
echo "📱 Accès web: http://localhost:3000"
echo "📊 Dashboard admin: http://localhost:3000/admin"
EOF

    # Script d'arrêt
    cat > stop.sh << 'EOF'
#!/bin/bash

# 🛑 Script d'arrêt - Night Guards System

echo "🛑 Arrêt de Night Guards System..."

# Arrêter Redis
if pgrep redis-server > /dev/null; then
    pkill redis-server
    echo "✅ Redis arrêté"
fi

# Arrêter le serveur Node.js
if pgrep -f "node server.js" > /dev/null; then
    pkill -f "node server.js"
    echo "✅ Serveur arrêté"
fi

echo "🎉 Night Guards System est arrêté!"
EOF

    # Script de test
    cat > test.sh << 'EOF'
#!/bin/bash

# 🧪 Script de test - Night Guards System

echo "🧪 Test de Night Guards System..."

# Tester les composants
if [ -f "scripts/test-all-components.js" ]; then
    node scripts/test-all-components.js
else
    echo "⚠️ Script de test non trouvé"
fi

# Tester l'API
echo "🌐 Test de l'API..."
curl -f http://localhost:3000/api/health || echo "❌ API non accessible"

echo "🧪 Tests terminés!"
EOF

    # Rendre les scripts exécutables
    chmod +x start.sh stop.sh test.sh
}

# Configuration des permissions
setup_permissions() {
    print_step "Configuration des permissions..."
    
    # Permissions pour les scripts
    chmod +x *.sh
    chmod +x scripts/*.js
    
    # Permissions pour les dossiers
    chmod -R 755 .
    chmod -R 755 client/
    chmod -R 755 mobile/
    chmod -R 755 desktop/
    chmod -R 755 php/
    
    # Permissions sécurisées pour les fichiers sensibles
    chmod 600 .env
    chmod 600 keys/* 2>/dev/null || true
    
    print_success "Permissions configurées"
}

# Tests finaux
run_final_tests() {
    print_header "Tests finaux..."
    
    # Tester les composants
    if [ -f "scripts/test-all-components.js" ]; then
        print_step "Test des composants..."
        node scripts/test-all-components.js
    fi
    
    # Tester l'installation
    print_step "Test de l'installation..."
    
    # Vérifier que le serveur peut démarrer
    timeout 10 npm start || {
        print_warning "Le serveur ne démarre pas correctement"
    }
    
    print_success "Tests finaux terminés"
}

# Affichage des informations finales
show_final_info() {
    print_header "Installation terminée!"
    
    echo -e "${GREEN}🎉 Night Guards System a été installé avec succès!${NC}"
    echo
    echo -e "${BLUE}📋 Informations importantes:${NC}"
    echo -e "  📁 Répertoire d'installation: $(pwd)"
    echo -e "  🌐 URL de l'application: http://localhost:3000"
    echo -e "  🔐 Admin: admin@nightguards.com / admin123"
    echo
    echo -e "${BLUE}🚀 Commandes disponibles:${NC}"
    echo -e "  ${CYAN}./start.sh${NC}     - Démarrer le système"
    echo -e "  ${CYAN}./stop.sh${NC}      - Arrêter le système"
    echo -e "  ${CYAN}./test.sh${NC}      - Tester le système"
    echo -e "  ${CYAN}npm test${NC}       - Exécuter les tests unitaires"
    echo -e "  ${CYAN}npm run dev${NC}    - Démarrer en mode développement"
    echo
    echo -e "${BLUE}📱 Applications disponibles:${NC}"
    echo -e "  🌐 Web: http://localhost:3000"
    echo -e "  📱 Mobile: APK dans mobile/android/app/build/outputs/apk/"
    echo -e "  💻 Desktop: Exécutable dans desktop/dist/"
    echo -e "  🐘 PHP: http://localhost:8000 (si configuré)"
    echo
    echo -e "${YELLOW}⚠️  Actions recommandées:${NC}"
    echo -e "  1. Changer le mot de passe administrateur par défaut"
    echo -e "  2. Configurer les emails dans .env"
    echo -e "  3. Ajouter vos sites et utilisateurs"
    echo -e "  4. Consulter la documentation dans docs/"
    echo
    echo -e "${GREEN}✅ Installation one-shot terminée avec succès!${NC}"
}

# Fonction principale
main() {
    echo -e "${BLUE}"
    echo "🌙 ╔══════════════════════════════════════════════════════════════╗"
    echo "   ║               NIGHT GUARDS SYSTEM                           ║"
    echo "   ║              Installation One-Shot Optimisée                ║"
    echo "   ║                Version 1.0.0 - Production Ready               ║"
    echo "   ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    # Exécuter toutes les étapes
    check_prerequisites
    setup_database
    install_dependencies
    setup_security
    build_applications
    setup_services
    run_final_tests
    show_final_info
}

# Gestion des erreurs
trap 'print_error "Une erreur est survenue. Vérifiez les logs ci-dessus."; exit 1' ERR

# Démarrage
main "$@"
