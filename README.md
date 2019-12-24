# teamcity-agent-dotnet-core
TeamCity .NET Core Agent Dockerfile

[![Docker Automated buil](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/jkleczkowski/teamcity-agent-dotnet-core/builds/)

Based on official `debian/buster` image.

To get this image, use command:

```sh
docker pull jkleczkowski/teamcity-agent-dotnet-core
```

Components:
```
    wget
    curl
    mc
    unzip
    git
    mercurial
    openjdk-11-jdk
    apt-transport-https
    apt-utils
    lxc
    iptables
    ca-certificates
    docker.io
    mono-devel mono-xbuild maven
    libmono-addins-*
    build-essential
    libssl-dev
    libffi-dev
    python3-dev
    python3-venv
    #install ruby & packer
    ruby p7zip-full
    nodejs v13.x
    gcc
    g++
    yarn
    build-essential
    npm
    bower
    gulp
    @angular/cli
    libkrb5-dev
    python-pip
    krb5-user
    pywinrm (pip)
    ansible (pip)
    packer (https://packer.io)
    powershell (7.0.0-rc.1)

    latest:
        dotnet-sdk-3.1
    full:
        dotnet-sdk-2.1
        dotnet-sdk-2.2
        dotnet-sdk-3.0
        dotnet-sdk-3.1
```
