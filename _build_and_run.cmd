docker build -t arti.ksoft.biz/docker-local/team-city/teamcity-agent-dotnet-core:latest .
@rem docker build -t jkleczkowski/teamcity-agent-dotnet-core:full --build-args CORE_VERSIONS="dotnet-sdk-2.1 dotnet-sdk-2.2 dotnet-sdk-3.0 dotnet-sdk-3.1" .

@rem docker rm tca --force

@rem docker run --rm --name tca -v c:/DockerBuildAgent/conf:/data/teamcity_agent/conf -v c:/DockerBuildAgent/work:/opt/buildagent/work jkleczkowski/teamcity-agent-dotnet-core:full

@rem docker tag jkleczkowski/teamcity-agent-dotnet-core:next jkleczkowski/teamcity-agent-dotnet-core:latest
@rem docker push jkleczkowski/teamcity-agent-dotnet-core:latest
docker push arti.ksoft.biz/docker-local/team-city/teamcity-agent-dotnet-core