FROM debian:bookworm
#LABEL maintainer "Jacek Kleczkowski <jacek@ksoft.biz>"

#RUN apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*
VOLUME /var/lib/docker
VOLUME /opt/buildagent/work
VOLUME /opt/buildagent/logs
VOLUME /data/teamcity_agent/conf
VOLUME /opt/buildagent/plugins

ENV DOCKER_HOST "unix:///var/run/docker.sock"
ENV DOCKER_BIN "/usr/bin/docker"
ENV DOCKER_IN_DOCKER start
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV AGENT_CONF_FILE_NAME "buildAgent.properties"

EXPOSE 9090
# RUN  cat /opt/buildagent/bin/agent.sh
ENTRYPOINT [ "/bin/bash","/run-services.sh" ]

WORKDIR /

RUN apt-get update 

RUN apt-get install -y \
    wget curl mc \
    unzip \
    git \
    mercurial \
    openjdk-17-jdk \
    apt-transport-https \
    apt-utils \
    lxc \
    iptables \
    ca-certificates \
    ssh \
    docker.io \
    ca-certificates curl gnupg \
    --no-install-recommends && \
    # add-apt-repository ppa:ansible/ansible-2.9 && \
    wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && \
    #wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb && \
    apt-get update 

# # install build tools
RUN DEBIAN_FRONTEND=noninteractive DOTNET_CLI_TELEMETRY_OPTOUT=1 apt-get install -y \
    --no-install-recommends \
    # # install mono-devel
    mono-devel mono-xbuild maven \
    libmono-addins-* \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-full \
    libkrb5-dev \
    python3-pip \
    krb5-user \
    ruby p7zip-full && \
    rm /usr/lib/python3.11/EXTERNALLY-MANAGED

# # install web tools which are required for "dotnet publish" command
# # install nodejs, gcc, g++ build-essantials
RUN mkdir -p /etc/apt/keyrings &&  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \    
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install nodejs gcc g++ build-essential -y && \    
    npm i -g npm bower gulp @angular/cli

# Install yarn after installing npm
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -  && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn -y


RUN python3 -m pip install --upgrade pip setuptools && \
    python3 -m pip install ansible pywinrm pywinrm[kerberos] kerberos requests requests-kerberos 

RUN ansible-galaxy collection install \
    community.kubernetes \
    community.crypto \
    community.general \
    community.libvirt

#installing packer
RUN wget -q -O /tmp/packer.zip  https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_linux_amd64.zip && \
    unzip /tmp/packer.zip -d /usr/bin && \ 
    # rm -f -r /tmp/* && \
    chmod 0755 /usr/bin/packer && \
    # installing build agent
    curl -o /tmp/buildAgent.zip -k https://teamcity.ksoft.biz/update/buildAgent.zip && \
    unzip /tmp/buildAgent.zip -d /opt/buildagent && \
    mkdir -p /data/teamcity_agent/conf && \
    cp -r /opt/buildagent/conf /opt/buildagent/conf_dist && \
    # ls -al /opt/buildagent/conf_dist/ && \
    rm -f -r /tmp/*
COPY root/ /
RUN chmod 0755 /run-*.sh /services/*

#ARG CORE_VERSIONS="dotnet-sdk-2.1 dotnet-sdk-2.2 dotnet-sdk-3.0 dotnet-sdk-3.1"
ARG CORE_VERSIONS="dotnet-sdk-7.0"
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ${CORE_VERSIONS}

# Install PowerShell global tool
ENV POWERSHELL_VERSION=7.3.0 \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Debian-12

RUN curl -SL --output PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg https://pwshtool.blob.core.windows.net/tool/$POWERSHELL_VERSION/PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg \
    && mkdir -p /usr/share/powershell \
    && dotnet tool install --add-source / --tool-path /usr/share/powershell --version $POWERSHELL_VERSION PowerShell.Linux.x64 \
    && rm PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg \
    && ln -s /usr/share/powershell/pwsh /usr/bin/pwsh \
    && chmod 755 /usr/share/powershell/pwsh \
    # To reduce image size, remove the copy nupkg that nuget keeps.
    && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm \
    && rm -f -r /tmp/*

#dodanie kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl


RUN apt-get upgrade -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

