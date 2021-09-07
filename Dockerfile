# ===== get Ghidra source =====

FROM debian:latest AS ghidra-source
ARG GHIDRA_TAG=Ghidra_10.0.2_build
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install -y git 

RUN \
    cd / && \
    git clone https://github.com/NationalSecurityAgency/ghidra.git /src && \
    cd /src && \
    git checkout ${GHIDRA_TAG}


# ===== download Gradle =====

FROM debian:latest AS gradle-download
ARG GRADLE_VER=6.9.1
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install -y \
        curl \
        unzip

RUN \
    curl -o /gradle.zip https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VER}-bin.zip && \
    unzip /gradle.zip -d /opt && \
    mv /opt/gradle-* /opt/gradle



# ===== Build Ghidra =====

FROM debian:latest AS ghidra-build
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install -y \
        curl \
        default-jre \
        default-jdk \
        gcc \
        g++ \
        git 

COPY --from=gradle-download /opt/gradle /opt/gradle

COPY --from=ghidra-source /src /src
WORKDIR /src

RUN \
    /opt/gradle/bin/gradle -I gradle/support/fetchDependencies.gradle init
RUN \
    /opt/gradle/bin/gradle buildGhidra


# ===== Run Ghidra =====

FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install -y \
        curl \
        default-jre \
        default-jdk \
        git \
        unzip \
        xauth

COPY --from=ghidra-build /src/build/dist/ghidra_*.zip /tmp/ghidra.zip
RUN \
    unzip /tmp/ghidra.zip -d /opt \
    && mv /opt/ghidra* /opt/ghidra

RUN \
    useradd -m -d /home/user -s /bin/bash user

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT /docker-entrypoint.sh

ENV X_DISPLAY=host.docker.internal:0
ENV X_AUTHC_PROTO=MIT-MAGIC-COOKIE-1
ENV X_AUTHC_COOKIE='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

USER user


