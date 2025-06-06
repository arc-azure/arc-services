FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instala dependencias básicas
RUN apt-get update && apt-get install -y \
    curl unzip jq git sudo libicu66 ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Agrega un usuario para ejecutar el runner
RUN useradd -m runner && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Descarga la última versión del runner
ENV RUNNER_VERSION=2.316.0
WORKDIR /home/runner

RUN curl -Ls https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    | tar xz --no-same-owner

# Instala dependencias del runner
RUN ./bin/installdependencies.sh

# Cambia permisos
RUN chown -R runner:runner /home/runner

# Runner working directory
ENV RUNNER_WORKDIR=/home/runner/_work

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Cambia a usuario runner (¡al final!)
USER runner

ENTRYPOINT ["/entrypoint.sh"]
