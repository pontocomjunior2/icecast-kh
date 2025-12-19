FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências
RUN apt-get update && apt-get install -y \
    build-essential \
    libxslt-dev \
    libvorbis-dev \
    libxml2-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/icecast-kh

# Copiar código fonte
COPY . .

# Compilar e instalar
RUN ./configure --with-openssl && \
    make && \
    make install

# Criar diretórios necessários
RUN mkdir -p /etc/icecast-kh /var/log/icecast-kh && \
    useradd -r -s /bin/false icecast

# Copiar configuração customizada
COPY icecast.xml /etc/icecast-kh/icecast.xml

# Ajustar permissões
RUN chown -R icecast:icecast /var/log/icecast-kh /etc/icecast-kh

# Expor portas (8080 para web, 9000 para encoders)
EXPOSE 8080 9000

# Usuário não-root
USER icecast

CMD ["/usr/local/bin/icecast", "-c", "/etc/icecast-kh/icecast.xml"]
