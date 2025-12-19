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

echo "Configurando icecast.xml com variáveis de ambiente..."
envsubst < /etc/icecast-kh/icecast.xml.template > /etc/icecast-kh/icecast.xml

# Garantir que o icecast tenha permissão de leitura no arquivo gerado
# Já que o entrypoint roda como root inicialmente ou o usuário do Dockerfile
# Mas vamos garantir que o comando final rode com o comando correto

exec "$@"
