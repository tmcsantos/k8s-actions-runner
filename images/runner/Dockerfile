FROM ubuntu:18.04

ARG RUNNER_VERSION=2.164.0
ENV RUNNER_CONFIG /app

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    lsb-release \
    jq \
    software-properties-common \
    git \
    inetutils-ping \
    sudo

# install docker-cli
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y \
    docker-ce

# Create github user and pull runner binary
RUN useradd -ms /bin/bash github && \
    mkdir -p /app /usr/share/runner/ref && \
    cd /usr/share/runner/ref && \
    curl -fsSL https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz | tar -xz && \
    bash /usr/share/runner/ref/bin/installdependencies.sh && \
    chown -R github:github /app /usr/share/runner/ref

# hook up the runner user with passwordless sudo
RUN  echo "github ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/github && \
     chmod 0440 /etc/sudoers.d/github

COPY actions-runner.sh /usr/local/bin/actions-runner.sh
COPY removeRunner.sh /usr/local/bin/removeRunner.sh

USER github
WORKDIR /home/github
ENTRYPOINT ["/usr/local/bin/actions-runner.sh"]
