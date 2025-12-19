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
    gettext-base \
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

# Copiar template e script de entrada
COPY icecast.xml.template /etc/icecast-kh/icecast.xml.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ajustar permissões
RUN chown -R icecast:icecast /var/log/icecast-kh /etc/icecast-kh /entrypoint.sh

# Expor portas padrão (Pode ser alterado via variáveis de ambiente)
EXPOSE 8080 9000

# O entrypoint rodará como root para poder gerar o arquivo icecast.xml no /etc
# mas o comando final do Icecast será executado via 'exec'
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/bin/icecast", "-c", "/etc/icecast-kh/icecast.xml"]
