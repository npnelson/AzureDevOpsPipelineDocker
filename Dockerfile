FROM mcr.microsoft.com/mssql/server:2019-latest


# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=password1!
ENV MSSQL_PID=EXPRESS
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes


#Need to install java for sonarcloud

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
        zlib1g   \
        fontconfig \
        locales \
&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*   
    
ENV JAVA_VERSION jdk-11.0.9+11

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         ESUM='f90c6f941a95e20e305870700328804e5b48acb69d4928dc9c4627b3c755ae8a'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9%2B11.1/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.9_11.tar.gz'; \
         ;; \
       armhf|armv7l) \
         ESUM='082a13a9a5fbcf7ca45e67ab39e9682a9ef9e3779395e37aa0bf235e42a8eaf5'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9%2B11/OpenJDK11U-jdk_arm_linux_hotspot_11.0.9_11.tar.gz'; \
         ;; \
       ppc64el|ppc64le) \
         ESUM='5c619e9acc182b0e40391c8c378ede120bb4ef7b8f0312d582d7aa1ecc684bd6'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9%2B11/OpenJDK11U-jdk_ppc64le_linux_hotspot_11.0.9_11.tar.gz'; \
         ;; \
       s390x) \
         ESUM='e5cf6026a37db22133c671e4643e9735f8a9e8b85aa5a30f0dbeac8367d0a6a7'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9%2B11/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.9_11.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='a3c52b73a76bed0f113604165eb4f2020b767e188704d8cc0bfc8bc4eb596712'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9%2B11.1/OpenJDK11U-jdk_x64_linux_hotspot_11.0.9_11.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
