FROM jetbrains/teamcity-agent
LABEL maintainer "Jacek Kleczkowski <jacek@ksoft.biz>"

VOLUME /opt/buildagent/work
VOLUME /opt/buildagent/logs
VOLUME /data/teamcity_agent/conf

# image is based on Ubuntu 15 - fix for .NET Core installation
RUN apt-get install wget -y && \
    wget http://launchpadlibrarian.net/201330288/libicu52_52.1-8_amd64.deb && \
    dpkg -i libicu52_52.1-8_amd64.deb

# install .NET Core
RUN sh -c 'echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet-release/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install mc -y && \
    apt-get install dotnet-dev-1.0.1 -y && \
    apt-get install mono-devel mono-xbuild libmono-addins-* -y && \
    

# install web tools which are required for "dotnet publish" command
RUN apt-get install npm -y && \
    npm install npm -g && \
    npm install bower gulp -g


