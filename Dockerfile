FROM ubuntu:18.04

ENV LANG=C.UTF-8

# Instalar dependências (Ubuntu 18.04 - Era nativa do Icecast-KH)
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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/icecast-kh

# Copiar código fonte
COPY . .

# Limpar, converter scripts e compilar
# -fcommon e -O0 evitam erros de otimização/memória em códigos legacy
RUN dos2unix configure GIT-VERSION-GEN autogen.sh && \
    chmod +x ./configure ./GIT-VERSION-GEN ./autogen.sh && \
    ./configure --with-openssl CFLAGS="-fcommon -O0 -g" && \
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
