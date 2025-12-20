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
# Definir padrões se não definidos
export ICECAST_LOG_LEVEL=${ICECAST_LOG_LEVEL:-3}

echo "--- Diagnóstico de Inicialização ---"
echo "Usuário atual: $(whoami)"
echo "Localização do binário: $(which icecast)"
ldd $(which icecast)

echo "Verificando arquivos web..."
ls -R /usr/local/share/icecast/web | head -n 10

echo "Configurando icecast.xml..."
envsubst < /etc/icecast-kh/icecast.xml.template > /etc/icecast-kh/icecast.xml
dos2unix /etc/icecast-kh/icecast.xml

echo "--- Conteúdo do XML Gerado ---"
cat /etc/icecast-kh/icecast.xml
echo "------------------------------"

# Garantir permissões
mkdir -p /var/log/icecast-kh
touch /var/log/icecast-kh/access.log /var/log/icecast-kh/error.log
chown -R icecast:icecast /var/log/icecast-kh /etc/icecast-kh /usr/local/share/icecast

# Mostrar os logs no console sem usar symlinks (evita SegFault)
tail -f /var/log/icecast-kh/error.log /var/log/icecast-kh/access.log &

echo "Iniciando Icecast (Root -> Drop Privileges)..."
# O daemon=0 no XML garante que ele não feche o processo
exec /usr/local/bin/icecast -c /etc/icecast-kh/icecast.xml
