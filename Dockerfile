FROM debian:buster
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
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

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
    openjdk-11-jdk \
    apt-transport-https \
    apt-utils \
    lxc \
    iptables \
    ca-certificates \
    ssh \
    docker.io \
    --no-install-recommends && \
    # add-apt-repository ppa:ansible/ansible-2.9 && \
    wget -q https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && \
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
    python-dev \ 
#    python-venv \
    #install ruby & packer
    ruby p7zip-full

# # install web tools which are required for "dotnet publish" command
# # install nodejs, gcc, g++ yarn build-essantials
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -  && \
    apt-get install -y nodejs gcc g++ yarn build-essential && \
    npm i -g npm bower gulp @angular/cli

# install ansible & maven
#RUN add-apt-repository ppa:ansible/ansible-2.9 && \
#RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libkrb5-dev \
    python-pip \
    krb5-user && \
    python--use-deprecated=legacy-resolver -m pip install --upgrade pip && \
    python--use-deprecated=legacy-resolver -m pip install ansible && \
    python--use-deprecated=legacy-resolver -m pip install pywinrm && \
    python--use-deprecated=legacy-resolver -m pip install pywinrm[kerberos] && \
    python--use-deprecated=legacy-resolver -m pip install kerberos && \
    python--use-deprecated=legacy-resolver -m pip install requests && \
    python--use-deprecated=legacy-resolver -m pip install requests-kerberos && \
    python--use-deprecated=legacy-resolver -m pip install --upgrade setuptools && \
    apt-get clean

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
ARG CORE_VERSIONS="dotnet-sdk-3.1"
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ${CORE_VERSIONS}

# Install PowerShell global tool
ENV POWERSHELL_VERSION=7.0.0-rc.1 \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Debian-10

RUN curl -SL --output PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg https://pwshtool.blob.core.windows.net/tool/$POWERSHELL_VERSION/PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg \
    # && powershell_sha512='0fb0167e13560371bffec38a4a87bf39377fa1a5cc39b3a078ddec8803212bede73e5821861036ba5c345bd55c74703134c9b55c49385f87dae9e2de9239f5d9' \
    # && echo "$powershell_sha512  PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg" | sha512sum -c - \
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


RUN apt-get upgrade -y 


