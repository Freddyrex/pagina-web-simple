#!/usr/bin/env bash
#
# deploy.sh - Despliega un proyecto web en Apache con HTTP (:80) y HTTPS (:443)
# Uso: ./deploy.sh --project RUTA_PROYECTO --domain DOMINIO.LOCAL [--no-open]
#
set -euo pipefail

PROJECT=""
DOMAIN=""
OPEN_BROWSER=true
WWW_ROOT="/var/www"
SITES_DIR="/etc/apache2/sites-available"
SSL_DIR="/etc/apache2/ssl"

usage() {
    echo "Uso: $0 --project RUTA_PROYECTO --domain DOMINIO.LOCAL [--no-open]"
    echo "Ejemplo: ./deploy.sh --project \"\$HOME/Documentos/aplicaciones web\" --domain aplicaciones-web.local"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT="${2:-}"; shift 2 ;;
        --domain)  DOMAIN="${2:-}";  shift 2 ;;
        --no-open) OPEN_BROWSER=false; shift ;;
        *) usage ;;
    esac
done

[[ -z "$PROJECT" || -z "$DOMAIN" ]] && usage
[[ ! "$DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+$ ]] && { echo "ERROR: dominio inválido: $DOMAIN"; exit 1; }
[[ -d "$PROJECT" ]] || { echo "ERROR: no existe el proyecto: $PROJECT"; exit 1; }

PROJECT="$(realpath "$PROJECT")"
SITE_DIR="$WWW_ROOT/$DOMAIN"

step() { printf '\n[%s] %s\n' "$1" "$2"; }

sudo -v || { echo "ERROR: se requieren permisos de sudo"; exit 1; }

# [1] Detectar Apache
step 1 "Detectando Apache"
command -v apache2 >/dev/null 2>&1 || command -v apachectl >/dev/null 2>&1 \
    || { echo "ERROR: Apache no está instalado (apt install apache2)"; exit 1; }
systemctl is-active --quiet apache2 || sudo systemctl enable --now apache2
echo "Apache detectado y activo"

# [2] Crear directorio del sitio
step 2 "Creando $SITE_DIR"
sudo mkdir -p "$SITE_DIR"

# [3] Copiar proyecto
step 3 "Copiando proyecto desde $PROJECT"
if command -v rsync >/dev/null 2>&1; then
    sudo rsync -a --exclude 'deploy.sh' "$PROJECT"/ "$SITE_DIR"/
else
    sudo cp -a "$PROJECT"/. "$SITE_DIR"/
    sudo rm -f "$SITE_DIR/deploy.sh"
fi

# [4] Asegurar permisos legibles por Apache
step 4 "Fijando permisos legibles por Apache"
sudo chown -R root:www-data "$SITE_DIR"
sudo find "$SITE_DIR" -type d -exec chmod 755 {} +
sudo find "$SITE_DIR" -type f -exec chmod 644 {} +
sudo a2enmod mime >/dev/null 2>&1 || true
echo "Permisos y módulo mime configurados"

# [5] VirtualHost HTTP :80
step 5 "Creando VirtualHost :80 ($DOMAIN.conf)"
sudo tee "$SITES_DIR/$DOMAIN.conf" >/dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN

    DocumentRoot $SITE_DIR

    <Directory $SITE_DIR>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined
</VirtualHost>
EOF

# [6] Certificado con SAN (mkcert si está disponible, si no autofirmado)
step 6 "Generando certificado SSL con SAN DNS:$DOMAIN"
sudo mkdir -p "$SSL_DIR"
CAROOT="${CAROOT:-$HOME/.local/share/mkcert}"
if command -v mkcert >/dev/null 2>&1 && [[ -f "$CAROOT/rootCA.pem" ]]; then
    sudo env CAROOT="$CAROOT" mkcert \
        -cert-file "$SSL_DIR/$DOMAIN.crt" \
        -key-file "$SSL_DIR/$DOMAIN.key" "$DOMAIN"
    echo "Certificado emitido por la CA local de mkcert (sin advertencias)"
else
    sudo openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$SSL_DIR/$DOMAIN.key" \
        -out "$SSL_DIR/$DOMAIN.crt" \
        -subj "/C=PE/O=Freddy/CN=$DOMAIN" \
        -addext "subjectAltName=DNS:$DOMAIN" 2>/dev/null
    echo "AVISO: certificado autofirmado (instala mkcert para evitar advertencias)"
fi
sudo chmod 600 "$SSL_DIR/$DOMAIN.key"

# [7] VirtualHost HTTPS :443
step 7 "Creando VirtualHost :443 ($DOMAIN-ssl.conf)"
sudo tee "$SITES_DIR/$DOMAIN-ssl.conf" >/dev/null <<EOF
<VirtualHost *:443>
    ServerName $DOMAIN

    DocumentRoot $SITE_DIR

    SSLEngine on

    SSLCertificateFile $SSL_DIR/$DOMAIN.crt
    SSLCertificateKeyFile $SSL_DIR/$DOMAIN.key

    <Directory $SITE_DIR>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-ssl-access.log combined
</VirtualHost>
EOF

# [8] Modificar /etc/hosts
step 8 "Configurando resolución local en /etc/hosts"
if grep -qE "[[:space:]]$DOMAIN([[:space:]]|\$)" /etc/hosts; then
    echo "La entrada para $DOMAIN ya existe"
else
    echo "127.0.0.1	$DOMAIN" | sudo tee -a /etc/hosts >/dev/null
    echo "Añadido: 127.0.0.1 -> $DOMAIN"
fi

# [9] Validar configuración de Apache
step 9 "Validando configuración de Apache"
sudo a2enmod ssl >/dev/null
sudo a2dissite 000-default.conf >/dev/null 2>&1 || true
sudo a2ensite "$DOMAIN.conf" "$DOMAIN-ssl.conf" >/dev/null
sudo apache2ctl configtest

# [10] Recargar Apache
step 10 "Recargando Apache"
sudo systemctl reload apache2

# [11] Verificar y abrir navegador
step 11 "Verificación final"
sleep 1
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' "http://$DOMAIN" || true)
HTTPS_CODE=$(curl -sk -o /dev/null -w '%{http_code}' "https://$DOMAIN" || true)
echo "  http://$DOMAIN   -> HTTP $HTTP_CODE"
echo "  https://$DOMAIN  -> HTTPS $HTTPS_CODE"

if [[ "$OPEN_BROWSER" == true ]]; then
    xdg-open "https://$DOMAIN" >/dev/null 2>&1 || true
fi

printf '\nDespliegue completado:\n'
printf '  Sitio:    %s\n' "$SITE_DIR"
printf '  Dominio:  %s -> 127.0.0.1\n' "$DOMAIN"
printf '  HTTP:     http://%s\n' "$DOMAIN"
printf '  HTTPS:    https://%s (advertencia de autofirmado esperada)\n' "$DOMAIN"
