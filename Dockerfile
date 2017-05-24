FROM ubuntu:16.04
MAINTAINER joegagliardo

EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030

# MYSQL Passwords
ARG MYSQLROOT_PASSWORD=rootpassword

# Versions
ARG MAVEN_VERSION=3.5.0
ARG MAVEN_BASE_URL=http://apache.claz.org/maven/maven-3
ARG MAVEN_URL=${MAVEN_BASE_URL}/${MAVEN_VERSION}/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

ARG SCALA_VERSION=2.11.11
ARG SCALA_BASE_URL=http://www.scala-lang.org/files/archive
ARG SCALA_URL=${SCALA_BASE_URL}/scala-${SCALA_VERSION}.deb

ARG SBT_VERSION=0.13.15
ARG SBT_BASE_URL=https://dl.bintray.com/sbt/debian/sbt
ARG SBT_URL=${SBT_BASE_URL}-${SBT_VERSION}.deb

# Maven
ARG USER_HOME_DIR="/root"
ARG SHA=beb91419245395bd69a4a6edad5ca3ec1a8b64e41457672dc687c173a495f034

USER root

#    apt-get -y install curl tar sudo openssh-server openssh-client rsync nano vim && \
#    apt-get -y upgrade && \
#    apt-get -y install software-properties-common && \ 

# Install Dev Tools & Java
RUN apt-get update && \
    apt-get -y install curl tar sudo openssh-server openssh-client rsync nano vim software-properties-common git python2.7 gcc && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java8-installer build-essential && \
    mkdir /data && \
    mkdir /data/scripts && \
    cd /data && \
    mkdir /data/host && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    python3 get-pip.py && \
    rm /usr/local/bin/pip && \
    ln -s /usr/local/bin/pip2 /usr/local/bin/pip && \
    mv get-pip.py scripts && \
    pip2 install numpy && \
    pip3 install numpy && \
    pip2 install scipy && \
    pip3 install scipy && \
    pip2 install pandas && \
    pip3 install pandas && \
    pip2 install cherrypy && \
    pip3 install cherrypy && \
    echo "#! /bin/sh" > /data/scripts/install-matplotlib.sh && \
    echo "apt-get -y build-dep python-matplotlib" >> /data/scripts/install-matplotlib.sh && \
    echo "pip2 install matplotlib" >> /data/scripts/install-matplotlib.sh && \
    echo "pip3 install matplotlib" >> /data/scripts/install-matplotlib.sh && \
    chmod +x /data/scripts/install-matplotlib.sh && \
    echo "# sqlite3" && \
    echo "# MYSQL" && \
    echo "mysql-server-5.5 mysql-server/root_password password ${MYSQLROOT_PASSWORD}" | debconf-set-selections && \
    echo "mysql-server-5.5 mysql-server/root_password_again password ${MYSQLROOT_PASSWORD}" | debconf-set-selections && \
    apt-get -y install mysql-server mysql-client libmysql-java && \
    mkdir /data/host/mysql && \
    echo "[client]" > /etc/my.cnf && \
    echo "user=root" >> /etc/my.cnf && \
    echo "password=${MYSQLROOT_PASSWORD}" >> /etc/my.cnf && \
    echo "#! /bin/sh" > /data/scripts/start-mysql.sh && \
    echo "/etc/init.d/mysql start" >> /data/scripts/start-mysql.sh && \
    chmod +x /data/scripts/start-mysql.sh && \
    echo "#! /bin/sh" > /data/scripts/stop-mysql.sh && \
    echo "/etc/init.d/mysql stop" >> /data/scripts/stop-mysql.sh && \
    chmod +x /data/scripts/stop-mysql.sh && \
    /etc/init.d/mysql start && \
    echo "# Maven" && \
    echo ${MAVEN_URL} && \ 
    mkdir -p /usr/share/maven /usr/share/maven/ref && \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_URL} && \ 
    echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 && \
    rm -f /tmp/apache-maven.tar.gz && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \
    echo "# Scala" && \
    echo ${SCALA_URL} && \
    cd /data && \
    wget ${SCALA_URL} && \
    dpkg -i scala-${SCALA_VERSION}.deb && \
    rm scala-${SCALA_VERSION}.deb && \
    echo "# SBT" && \
    echo ${SBT_URL} && \
    cd /data && \
    wget ${SBT_URL} && \
    dpkg -i sbt-${SBT_VERSION}.deb && \
    cd /data && \
    apt-get install -f && \
    rm /data/sbt-${SBT_VERSION}.deb && \
    echo "Install R" && \
    echo "#! /bin/sh" > /data/scripts/install-r.sh && \
    echo "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9" >> /data/scripts/install-r.sh && \
    echo "add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'" >> /data/scripts/install-r.sh && \
    echo "apt-get update" >> /data/scripts/install-r.sh && \
    echo "apt-get -y install r-base" >> /data/scripts/install-r.sh && \
    chmod +x /data/scripts/install-r.sh && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "R and Matplot lib could not be installed during the building of the docker image" > /data/scripts/notes.txt && \
    echo "because they both prompt for a region and time zone, and I cannot figure out how to script" >> /data/scripts/notes.txt && \
    echo "default answers. So if you need either of these then run the corresponding install.sh for it" >> /data/scripts/notes.txt && \
    echo "" >> /data/scripts/notes.txt

ENV JAVA_HOME /usr
ENV PATH $PATH:$JAVA_HOME/bin:/data/scripts

#    apt-get remove scala-library scala && \
# R
# R must be installed by manually executing this script because it has a prompt for the region and time zone
# which I cannot automate


# trying various things to move mysql data folder so it's accessible outside the docker
#RUN mkdir /home/mysql \
#&& echo "[mysqld]" > /etc/my.cnf \
#&& echo "datadir=/home/mysql" >> /etc/my.cnf \
#&& echo "socket=/var/lib/mysql/mysql.sock" >> /etc/my.cnf \
#&& echo "user=root" >> /etc/my.cnf \
#&& echo "password=${MYSQLROOT_PASSWORD}" >> /etc/my.cnf \
#&& echo "# Disabling symbolic-links is recommended to prevent assorted security risks" >> /etc/my.cnf \
#&& echo "symbolic-links=0" >> /etc/my.cnf \
#&& echo "" >> /etc/my.cnf \
#&& echo "[mysqld_safe]" >> /etc/my.cnf \
#&& echo "log-error=/var/log/mysqld.log" >> /etc/my.cnf \
#&& echo "pid-file=/var/run/mysqld/mysqld.pid" >> /etc/my.cnf
#RUN rm /etc/my.cnf

#rsync -av /var/lib/mysql /home
#mv /var/lib/mysql /var/lib/mysql.bak
# sed -i 's/\/var\/lib\/mysql/\/home\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf

#RUN    rsync -av /var/lib/mysql /home
#RUN cp /etc/mysql/mysql.conf.d/mysqld.cnf /home
#RUN    sed -i 's/datadir= \t\/var\/lib\/mysql/datadir= \/home/\/mysql/' /home/mysqld.cnf
#RUN cp /home/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
#RUN    sed -i 's/datadir= \/var\/lib\/mysql/datadir= \/home/\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf


# .Net Core
#RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list' 
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 
#RUN apt-get update
#RUN sudo apt-get install dotnet-dev-1.0.4

#dotnet new console -o hwapp
#cd hwapp
#dotnet restore
#dotnet run

# 1. Build image
# mkdir ubuntudev
# copy this file into that folder
# docker build -t joegagliardo/ubuntudev -f UbuntuDeveloper.txt .

# 2. create a container and launch bash shell
# docker run --name ubuntutest -p 50070:50070 -p 8088:8088 -p 10020:10020 -it joegagliardo/ubuntudev /bin/bash -bash

# 3. create a container mapping a local folder ~/docker to the /data/host folder
# docker run --name ubuntutest -p 50070:50070 -p 8088:8088 -p 10020:10020 -v "$HOME/docker/:/data/host" -it joegagliardo/ubuntudev /bin/bash -bash
#/var/lib/mysql
# 4. reconnect to an existing container
#    docker start ubuntutest
#    docker attach ubuntutest

# maybe change ~ to go to home not root

#sed 
#RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
#sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
#sed s/root:x:0:0:root:\/root:\/bin\/bash/root:x:0:0:root:\/home:\/bin\/bash/ /etc/passwd > /etc/passwd#

#root:x:0:0:root:\/root:\/bin\/bash
#root:x:0:0:root:/root:/bin/bash
#root:x:0:0:root:/home:/bin/bash
#root:x:0:0:root:\/home:\/bin\/bash

#sed -i 's/root:x:0:0:root:\/root:\/bin\/bash/root:x:0:0:root:\/home:\/bin\/bash/' /etc/passwd
#cp /etc/passwd .
#root@1fc22532c51e:~# sed -i 's/root:x:0:0:root:\/root:\/bin\/bash/root:x:0:0:root:\/home:\/bin\/bash/' passwd
#root@1fc22532c51e:~# sudo cp passwd /etc/passwd

#pyspark
#mysql

#    apt-get remove -y nano && \
#    apt-get remove -y vim && \
#    apt-get remove -y curl && \
#    apt-get remove -y software-properties-common && \
#    apt-get remove -y oracle-java8-installer && \
#    apt-get remove -y build-essential
#    apt-get -y install sqlite3 libsqlite3-dev && \
#    apt-get remove -y sqlite3 && \
#    apt-get -y install mysql-server && \
#    apt-get -y install mysql-client && \
#    apt-get -y install libmysql-java && \
#    apt-get -y remove mysql-server && \
#    apt-get -y remove mysql-client && \
#    apt-get -y remove libmysql-java && \

# docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
# docker tag server:latest myname/server:latest
# docker commit 3a09b2588478 mynewimage
# docker save mynewimage > /tmp/mynewimage.tar
# docker load < /tmp/mynewimage.tar


# alias newub="docker run --name ubuntu-client -v \"$HOME/docker/:/data/host\" -it joegagliardo/ubuntu /etc/bootstrap.sh -bash"
# alias attachub="docker start ubuntu-client && docker attach ubuntu-client"

