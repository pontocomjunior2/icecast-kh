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
export ICECAST_LOG_LEVEL=${ICECAST_LOG_LEVEL:-3}

echo "--- Verificando Ambiente ---"
echo "Usuário: $(whoami)"
ls -ld /usr/local/share/icecast/web 2>/dev/null || echo "AVISO: webroot não encontrado em /usr/local/share/icecast/web"
which icecast || echo "AVISO: binário 'icecast' não encontrado no PATH"
[ -f /usr/local/bin/icecast ] || echo "AVISO: binário não encontrado em /usr/local/bin/icecast"

echo "Configurando icecast.xml com variáveis de ambiente..."
envsubst < /etc/icecast-kh/icecast.xml.template > /etc/icecast-kh/icecast.xml

# Garantir que o diretório de logs existe e tem permissão
mkdir -p /var/log/icecast-kh
chown -R icecast:icecast /var/log/icecast-kh /etc/icecast-kh

# Redirecionar logs para o console do Docker
ln -sf /dev/stdout /var/log/icecast-kh/access.log
ln -sf /dev/stderr /var/log/icecast-kh/error.log

# Executar o Icecast (ele iniciará como root e mudará para o usuário 'icecast' conforme o xml)
echo "Iniciando Icecast: $*"
exec "$@"
