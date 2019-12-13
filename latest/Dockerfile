FROM debian:buster
#LABEL maintainer "Jacek Kleczkowski <jacek@ksoft.biz>"

WORKDIR /

RUN apt-get update && apt-get upgrade -y 

RUN apt-get install wget curl mc unzip git mercurial openjdk-11-jdk -y --no-install-recommends
RUN apt-get install apt-transport-https apt-utils lxc iptables ca-certificates docker.io   -y --no-install-recommends
RUN wget -q https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb && apt update


RUN curl -o /tmp/buildAgent.zip -k https://teamcity.ksoft.biz/update/buildAgent.zip
RUN unzip /tmp/buildAgent.zip -d /opt/buildagent && \
    mkdir -p /data/teamcity_agent/conf

COPY  root/ /
#RUN chmod 0755 /run-*.sh /services/*


# RUN ls -al /
# install .NET Core

RUN DEBIAN_FRONTEND=noninteractive DOTNET_CLI_TELEMETRY_OPTOUT=1 apt-get install dotnet-sdk-2.1 -y 
RUN DEBIAN_FRONTEND=noninteractive DOTNET_CLI_TELEMETRY_OPTOUT=1 apt-get install dotnet-sdk-2.2 -y 
RUN DEBIAN_FRONTEND=noninteractive DOTNET_CLI_TELEMETRY_OPTOUT=1 apt-get install dotnet-sdk-3.0 -y 
RUN DEBIAN_FRONTEND=noninteractive DOTNET_CLI_TELEMETRY_OPTOUT=1 apt-get install dotnet-sdk-3.1 -y 

# RUN sh -c 'echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet-release/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list' && \
#     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 && \
#     apt-get update && \
#     apt-get install mc -y && \
#     apt-get upgrade -y && \
#     export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true 

# RUN apt-get install tzdata -y 

# # install .NET Core
# ENV DOTNET_VER "dotnet-sdk-2.0.0"
# #(apt-cache search dotnet-dev-2.0.0 | awk '{print $1}') | sh 
# RUN apt-get install ${DOTNET_VER} -y

# # install mono-devel
RUN apt-get install mono-devel mono-xbuild libmono-addins-* -y 

# # install web tools which are required for "dotnet publish" command
# # install nodejs, gcc, g++ yarn build-essantials
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -  && \
    apt-get install -y nodejs gcc g++ yarn build-essential && \
    npm i -g npm bower gulp

# install ansible
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt-get update && \
    apt-get install -y ansible

#install ruby & packer
RUN apt-get install -y ruby p7zip-full

# Install PowerShell global tool
ENV POWERSHELL_VERSION=7.0.0-preview.4 \
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Debian-10

RUN curl -SL --output PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg https://pwshtool.blob.core.windows.net/tool/$POWERSHELL_VERSION/PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg \
    && powershell_sha512='0fb0167e13560371bffec38a4a87bf39377fa1a5cc39b3a078ddec8803212bede73e5821861036ba5c345bd55c74703134c9b55c49385f87dae9e2de9239f5d9' \
    && echo "$powershell_sha512  PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg" | sha512sum -c - \
    && mkdir -p /usr/share/powershell \
    && dotnet tool install --add-source / --tool-path /usr/share/powershell --version $POWERSHELL_VERSION PowerShell.Linux.x64 \
    && rm PowerShell.Linux.x64.$POWERSHELL_VERSION.nupkg \
    && ln -s /usr/share/powershell/pwsh /usr/bin/pwsh \
    && chmod 755 /usr/share/powershell/pwsh \
    # To reduce image size, remove the copy nupkg that nuget keeps.
    && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm && \
    rm -f -r /tmp/*

#RUN apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*
VOLUME [ /var/lib/docker, /opt/buildagent/work, /opt/buildagent/logs, /data/teamcity_agent/conf, /opt/buildagent/plugins ]

ENV DOCKER_HOST ""
ENV DOCKER_BIN "/usr/bin/docker"
ENV DOCKER_IN_DOCKER start
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

EXPOSE 9090
# RUN  cat /opt/buildagent/bin/agent.sh
ENTRYPOINT [ "/run-services.sh" ]


