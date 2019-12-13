docker build -t jkleczkowski/teamcity-agent-dotnet-core:next .

docker rm tca --force

@rem 
docker run --rm --name tca -v c:/DockerBuildAgent/conf:/data/teamcity_agent/conf -v c:/DockerBuildAgent/work:/opt/buildagent/work jkleczkowski/teamcity-agent-dotnet-core:next
