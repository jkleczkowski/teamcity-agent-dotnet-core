FROM jetbrains/teamcity-agent

LABEL maintainer "Jacek K <support@ksoft.biz>"

RUN export DEBIAN_FRONTEND=noninteractive && \
    export DEBCONF_NONINTERACTIVE_SEEN=true 

# detecting ubuntu version
#RUN echo "$(lsb_release -r | egrep -o '([0-9]{1,2}\.[0-9]{1,2})' 2>&1)"
#RUN export SYS_VER=00.00
#RUN echo "Current ubuntu version is: ${SYS_VER}"

#RUN SYSVER="$(lsb_release -r | egrep -o '([0-9]{1,2}\.[0-9]{1,2})'  2>&1)"
# RUN SYSVER=$(lsb_release -r)

#RUN echo "Current ubuntu version is: ${SYSVER}"

# install .NET Core
RUN apt-get update 

RUN apt-get install apt-utils wget -y 

RUN wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -r | egrep -o '([0-9]{1,2}\.[0-9]{1,2})' 2>&1)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb

RUN apt-get update && \
    apt-get install -y apt-transport-https apt-utils 

RUN apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# install .NET Core
ENV DOTNET_VER "dotnet-sdk-3.0"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN export  DOTNET_CLI_TELEMETRY_OPTOUT=1
#RUN apt-cache search dotnet-sdk-2.2 aspnetcore-runtime-2.2

#(apt-cache search dotnet-dev-2.2.0 | awk '{print $1}') | sh 
RUN DEBIAN_FRONTEND=noninteractive  apt-get install dotnet-sdk-2.1 -y 
RUN DEBIAN_FRONTEND=noninteractive  apt-get install dotnet-sdk-2.2 -y 
RUN DEBIAN_FRONTEND=noninteractive  apt-get install dotnet-sdk-3.0 -y 

# install mono-devel
RUN DEBIAN_FRONTEND=noninteractive  apt-get install mono-devel mono-dbg mono-xbuild libmono-addins-* -y 

# install web tools which are required for "dotnet publish" command
RUN apt remove nodejs npm
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -

RUN apt-get install nodejs -y && \
    npm install npm -g && \
    npm install bower gulp -g

# install ansible
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt-get update && \
    apt-get install -y ansible

#install ruby & packer
RUN apt-get install -y ruby p7zip-full

#installing packer
RUN wget -q -O /tmp/packer.zip  https://releases.hashicorp.com/packer/1.3.3/packer_1.3.3_linux_amd64.zip && \
    unzip /tmp/packer.zip -d /usr/bin && \
    chmod 0755 /usr/bin/packer && \
    rm -f -r /tmp/*


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
    && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm

VOLUME [/opt/buildagent/work, /opt/buildagent/logs, /data/teamcity_agent/conf, /opt/buildagent/plugins ]

ENV DOCKER_HOST   \
    DOCKER_BIN "/usr/bin/docker" \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip

#RUN packer --version

