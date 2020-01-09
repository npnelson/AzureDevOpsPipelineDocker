FROM openjdk:11-stretch
#base on java image since some pipeline tasks (i.e. sonarcloud) require java
#Azure Pipelines agent only supports subset of .NET Core Linux flavors, so just pin to ubuntu 18.04 for now 

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

#Just kind of pieced these together - main source https://docs.microsoft.com/en-us/dotnet/core/install/dependencies?tabs=netcore31&pivots=os-linux 

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \        
        libunwind8 \
        netcat \
        liblttng-ust0 \      
        libkrb5-3 \
        libssl1.0.2 \
        libcurl3 \
        libicu57 \
        zlib1g      

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
