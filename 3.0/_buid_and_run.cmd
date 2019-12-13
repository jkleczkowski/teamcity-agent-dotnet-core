docker build -t jkleczkowski/teamcity-agent-dotnet-core .
docker rm tca --force

@rem -e SERVER_URL=https://teamcity.ksoft.biz 
@rem docker push jkleczkowski/teamcity-agent-dotnet-core
@rem docker run --rm --name tca -v c:/DockerBuildAgent/conf:/data/teamcity_agent/conf -v c:/DockerBuildAgent/work:/opt/buildagent/work jkleczkowski/teamcity-agent-dotnet-core

