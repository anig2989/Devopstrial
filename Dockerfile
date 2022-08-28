# node > 14.6.0 is required for the SFDX-Git-Delta plugin
FROM node:16

ARG PMD_VERSION='6.36.0'
ARG SFDX_VERSION='@7.109.0'
ENV PMD_VERSION=$PMD_VERSION

#add usefull tools
RUN apt update \
    echo y | apt install \
      git \
      findutils \
      bash \
      unzip \
      curl \
      wget \
      nodejs \
      openssh-client \
      jq \
      software-properties-common

# install Salesforce CLI from npm and plugins
RUN npm install sfdx-cli${SFDX_VERSION} --global \
    sfdx --version \
    echo y | sfdx plugins:install sfpowerkit \
    sfdx plugins

# Install OpenJDK-8
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt-get update && \
    mkdir -p /usr/share/man/man1 && \
    apt-get install -y --no-install-recommends adoptopenjdk-8-hotspot-jre && \
    exportJAVA_HOME="/usr/lib/jvm/adoptopenjdk-8-hotspot-jre-amd64" && \
    export PATH=$JAVA_HOME/bin:$PATH && \
    java -version

# Install PMD
RUN wget -nc -O pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases/${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip \
    && unzip pmd.zip \
    && rm -f pmd.zip \
    && mv pmd-bin-${PMD_VERSION} pmd \
    chmod +x /pmd
