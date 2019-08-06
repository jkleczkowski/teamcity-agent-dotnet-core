FROM jetbrains/teamcity-agent
LABEL maintainer "Jacek Kleczkowski <jacek@ksoft.biz>"

# image is based on Ubuntu 15 - fix for .NET Core installation
ADD libicu52_52.1-8_amd64.deb /tmp/libicu52_52.1-8_amd64.deb
RUN dpkg -i /tmp/libicu52_52.1-8_amd64.deb

# install .NET Core
RUN apt-get update && \
    apt-get install mc wget -y && \
    export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb

RUN apt-get install apt-transport-https && apt-get update

RUN apt-get upgrade -y

RUN apt-get install tzdata -y 

# install .NET Core
ENV DOTNET_VER "dotnet-sdk-2.1"

#RUN apt-cache search dotnet-sdk

#(apt-cache search dotnet-dev-2.1.0 | awk '{print $1}') | sh 
RUN apt-get install ${DOTNET_VER} -y

# install mono-devel
RUN apt-get install mono-devel mono-dbg mono-xbuild libmono-addins-* -y 

# install web tools which are required for "dotnet publish" command
RUN apt remove nodejs npm
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get install nodejs -y && \
    npm install npm -g && \
    npm install bower gulp -g

# install ansible
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt-get update && \
    apt-get install -y ansible

VOLUME /opt/buildagent/work
VOLUME /opt/buildagent/logs
VOLUME /data/teamcity_agent/conf
VOLUME /opt/buildagent/plugins

ENV DOCKER_HOST ""
ENV DOCKER_BIN "/usr/bin/docker"
