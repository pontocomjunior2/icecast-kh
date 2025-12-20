FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências (Debian Buster - Estável para Legacy)
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libxslt1-dev \
    libvorbis-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    curl \
    gettext-base \
    util-linux \
    dos2unix \
    mime-support \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/icecast-kh

# Copiar código fonte
COPY . .

# Limpar, converter scripts e compilar
# Usamos -fcommon para evitar problemas com GCC recente (correção do SegFault)
RUN dos2unix configure GIT-VERSION-GEN autogen.sh && \
    chmod +x ./configure ./GIT-VERSION-GEN ./autogen.sh && \
    ./configure --with-openssl CFLAGS="-fcommon" && \
    make clean && \
    make && \
    make install

# Criar diretórios necessários
RUN mkdir -p /etc/icecast-kh /var/log/icecast-kh && \
    groupadd -r icecast && \
    useradd -r -g icecast -s /bin/false icecast

# Copiar template e script de entrada
COPY icecast.xml.template /etc/icecast-kh/icecast.xml.template
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh /etc/icecast-kh/icecast.xml.template && \
    chmod +x /entrypoint.sh

# Ajustar permissões
RUN chown -R icecast:icecast /var/log/icecast-kh /etc/icecast-kh /usr/local/share/icecast /entrypoint.sh

# Expor portas padrão
EXPOSE 8080 9000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/bin/icecast", "-c", "/etc/icecast-kh/icecast.xml"]
