# joegagliardo/ubuntu
FROM ubuntu:18.10
MAINTAINER joegagliardo

EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030 3306

# MYSQL Passwords
ARG MYSQLROOT_PASSWORD=rootpassword
ARG MYSQL_PASSWORD=

USER root

# Versions
#ARG MAVEN_VERSION=3.5.2
#ARG MAVEN_BASE_URL=http://apache.claz.org/maven/maven-3
#ARG MAVEN_URL=${MAVEN_BASE_URL}/${MAVEN_VERSION}/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

#ARG SCALA_VERSION=2.11.11
#ARG SCALA_BASE_URL=http://www.scala-lang.org/files/archive
#ARG SCALA_URL=${SCALA_BASE_URL}/scala-${SCALA_VERSION}.deb
#http://www.scala-lang.org/files/archive/scala-2.11.11.deb

#ARG SBT_VERSION=1.1.0
#ARG SBT_BASE_URL=https://dl.bintray.com/sbt/debian/sbt
#ARG SBT_URL=${SBT_BASE_URL}-${SBT_VERSION}.deb

# Maven
#ARG USER_HOME_DIR="/root"
#ARG SHA=beb91419245395bd69a4a6edad5ca3ec1a8b64e41457672dc687c173a495f034

ARG DEBIAN_FRONTEND=noninteractive

USER root

# Install Dev Tools & Java
 RUN   echo "# ---------------------------------------------" && \
    echo "# Julia" && \
    echo "# ---------------------------------------------" && \
    curl --progress-bar https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.1-linux-x86_64.tar.gz | tar -xz -C /usr/local/ && \
    ln -s /usr/local/julia* /usr/local/julia 
ENV PATH $PATH:/usr/local/julia:$JAVA_HOME/bin:/scripts:/home

1226 UAL 341 pm
001231525323a
239a
L3BBKN
