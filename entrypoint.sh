#!/bin/sh

# Substituir variáveis de ambiente no template do icecast.xml
# Se a variável não estiver definida, o envsubst deixará vazio ou você pode definir padrões aqui
export ICECAST_SOURCE_PASSWORD=${ICECAST_SOURCE_PASSWORD:-hackme}
export ICECAST_RELAY_PASSWORD=${ICECAST_RELAY_PASSWORD:-hackme}
export ICECAST_ADMIN_USER=${ICECAST_ADMIN_USER:-admin}
export ICECAST_ADMIN_PASSWORD=${ICECAST_ADMIN_PASSWORD:-hackme}
export ICECAST_HOSTNAME=${ICECAST_HOSTNAME:-localhost}
export ICECAST_LOCATION=${ICECAST_LOCATION:-Brazil}
export ICECAST_ADMIN_EMAIL=${ICECAST_ADMIN_EMAIL:-admin@localhost}
export ICECAST_CLIENTS=${ICECAST_CLIENTS:-1000}
export ICECAST_SOURCES=${ICECAST_SOURCES:-100}
export ICECAST_WEB_PORT=${ICECAST_WEB_PORT:-8080}
export ICECAST_SOURCE_PORT=${ICECAST_SOURCE_PORT:-9000}

echo "Configurando icecast.xml com variáveis de ambiente..."
envsubst < /etc/icecast-kh/icecast.xml.template > /etc/icecast-kh/icecast.xml

# Garantir que o icecast tenha permissão nos arquivos e logs
chown -R icecast:icecast /etc/icecast-kh /var/log/icecast-kh

# Executar o comando final como o usuário 'icecast'
echo "Iniciando Icecast..."
exec su icecast -s /bin/sh -c "$*"
