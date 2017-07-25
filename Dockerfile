FROM ubuntu:16.04
MAINTAINER joegagliardo

EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030


# MYSQL Passwords
ARG MYSQLROOT_PASSWORD=rootpassword

USER root
# Versions
ARG MAVEN_VERSION=3.5.0
ARG MAVEN_BASE_URL=http://apache.claz.org/maven/maven-3
ARG MAVEN_URL=${MAVEN_BASE_URL}/${MAVEN_VERSION}/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

ARG SCALA_VERSION=2.11.11
ARG SCALA_BASE_URL=http://www.scala-lang.org/files/archive
ARG SCALA_URL=${SCALA_BASE_URL}/scala-${SCALA_VERSION}.deb
#http://www.scala-lang.org/files/archive/scala-2.11.11.deb

ARG SBT_VERSION=0.13.15
ARG SBT_BASE_URL=https://dl.bintray.com/sbt/debian/sbt
ARG SBT_URL=${SBT_BASE_URL}-${SBT_VERSION}.deb

# Maven
ARG USER_HOME_DIR="/root"
ARG SHA=beb91419245395bd69a4a6edad5ca3ec1a8b64e41457672dc687c173a495f034

USER root

# Install Dev Tools & Java
RUN apt-get update && \
    apt-get -y install curl tar sudo openssh-server openssh-client rsync nano vim software-properties-common git python2.7 gcc apt-utils netcat debconf apt-transport-https && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.utexas.edu/mariadb/repo/10.1/ubuntu xenial main' && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    mkdir /scripts && \
    mkdir /data && \
    mkdir /data/mysql && \
    cd /home && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java8-installer build-essential && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    python3 get-pip.py && \
    rm /usr/local/bin/pip && \
    ln -s /usr/local/bin/pip2 /usr/local/bin/pip && \
    mv get-pip.py /scripts && \
    pip2 install numpy && \
    pip3 install numpy && \
    pip2 install scipy && \
    pip3 install scipy && \
    pip2 install pandas && \
    pip3 install pandas && \
    pip2 install cherrypy && \
    pip3 install cherrypy && \
    pip2 install pymssql && \
    pip3 install pymssql && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq build-dep python-matplotlib && \
    pip2 install matplotlib && \
    pip3 install matplotlib && \
    echo "# nodejs" && \
    apt-get -y install nodejs && \
    apt-get -y install npm && \
    echo "# sqlite3" && \
    apt-get -y install sqlite3 libsqlite3-dev && \
    echo "# MariaDB" && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install mariadb-server mariadb-client && \
    echo "[client]" > /etc/my.cnf && \
    echo "user=root" >> /etc/my.cnf && \
    echo "password=" >> /etc/my.cnf && \
    echo "" >> /etc/my.cnf && \
    echo "#! /bin/sh" > /scripts/start-mysql.sh && \
    echo "service mysql start" >> /scripts/start-mysql.sh && \
    chmod +x /scripts/start-mysql.sh && \
    echo "#! /bin/sh" > /scripts/stop-mysql.sh && \
    echo "service mysql stop" >> /scripts/stop-mysql.sh && \
    chmod +x /scripts/stop-mysql.sh && \
    usermod -d /var/lib/mysql/ mysql && \
    /scripts/start-mysql.sh && \
    mysqladmin -u root password "${MYSQLROOT_PASSWORD}" && \
    sed -i 's/password=/password=${MYSQLROOT_PASSWORD}/' /etc/my.cnf && \
    echo "# Postgresql" && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install postgresql postgresql-contrib postgresql-client && \
    echo "#! /bin/sh" > /scripts/start-postgresql.sh && \
    echo "/etc/init.d/postgresql start" >> /scripts/start-postgresql.sh && \
    chmod +x /scripts/start-postgresql.sh && \
    echo "#! /bin/sh" > /scripts/postgres-client.sh && \
    echo "sudo -u postgres psql" >> /scripts/postgres-client.sh && \
    chmod +x /scripts/postgres-client.sh && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
	 apt-get update && \
    apt-get -y install apt-transport-https r-base && \
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
    cd /home && \
    wget ${SCALA_URL} && \
    dpkg -i scala-${SCALA_VERSION}.deb && \
    rm scala-${SCALA_VERSION}.deb && \
    echo "# SBT" && \
    echo ${SBT_URL} && \
    cd /home && \
    wget ${SBT_URL} && \
    dpkg -i sbt-${SBT_VERSION}.deb && \
    cd /home && \
    apt-get install -f && \
    rm /home/sbt-${SBT_VERSION}.deb && \
    echo "alias hist='f(){ history | grep \"\$1\";  unset -f f; }; f'" >> ~/.bashrc && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "" > /scripts/notes.txt && \
    echo "I switched to use MariaDB instead of MySQL since it has more features and is better maintanined" >> /scripts/notes.txt && \
    echo "" >> /scripts/notes.txt && \
	echo "# Final Cleanup" && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "*************" 

RUN echo "*************" && \
    echo "" >> /scripts/notes.txt

#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle/
ENV JAVA_HOME /usr
ENV PATH $PATH:$JAVA_HOME/bin:/scripts:/home


#    echo "Install R" && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
#    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
#	 apt-get update && \
#    apt-get -y install r-base && \

apt-get -y install apt-transport-https
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
	 apt-get update && \
    apt-get -y install apt-transport-https r-base 
