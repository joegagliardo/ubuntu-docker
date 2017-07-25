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
#http://www.scala-lang.org/files/archive/scala-2.11.11.deb

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
    apt-get -y install curl tar sudo openssh-server openssh-client rsync nano vim software-properties-common git python2.7 gcc netcat && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java8-installer build-essential && \
    mkdir /scripts && \
    mkdir /data && \
    cd /home && \
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
    echo "#! /bin/sh" > /scripts/install-matplotlib.sh && \
    echo "apt-get update"  >> /scripts/install-matplotlib.sh && \
    echo "apt-get -y build-dep python-matplotlib" >> /scripts/install-matplotlib.sh && \
    echo "pip2 install matplotlib" >> /scripts/install-matplotlib.sh && \
    chmod +x /scripts/install-matplotlib.sh && \
    pip3 install matplotlib && \
    echo "# nodejs" && \
    apt-get -y install nodejs && \
    apt-get -y install npm && \
    echo "# sqlite3" && \
    apt-get -y install sqlite3 libsqlite3-dev && \
    echo "# MYSQL" && \
    echo "mysql-server-5.5 mysql-server/root_password password ${MYSQLROOT_PASSWORD}" | debconf-set-selections && \
    echo "mysql-server-5.5 mysql-server/root_password_again password ${MYSQLROOT_PASSWORD}" | debconf-set-selections && \
    apt-get -y install mysql-server mysql-client libmysql-java && \
    mkdir /data/mysql && \
    echo "[client]" > /etc/my.cnf && \
    echo "user=root" >> /etc/my.cnf && \
    echo "password=${MYSQLROOT_PASSWORD}" >> /etc/my.cnf && \
    echo "#! /bin/sh" > /scripts/start-mysql.sh && \
    echo "/etc/init.d/mysql start" >> /scripts/start-mysql.sh && \
    chmod +x /scripts/start-mysql.sh && \
    echo "#! /bin/sh" > /scripts/stop-mysql.sh && \
    echo "/etc/init.d/mysql stop" >> /scripts/stop-mysql.sh && \
    chmod +x /scripts/stop-mysql.sh && \
    echo "#! /bin/sh" > /scripts/move-mysql.sh && \
    echo "# this is not yet working so don't do it." >> /scripts/move-mysql.sh && \
    echo "/etc/init.d/mysql stop" >> /scripts/move-mysql.sh && \
    echo "mv /var/lib/mysql /data/mysql" >> /scripts/move-mysql.sh && \
    echo "ln -s /data/mysql /var/lib/mysql" >> /scripts/move-mysql.sh && \
    echo "echo \"alias /var/lib/mysql/ -> /data/mysql,\" >> /etc/apparmor.d/tunables/alias" >> /scripts/move-mysql.sh && \
    echo "systemctl restart apparmor" >> /scripts/move-mysql.sh && \
    echo "/etc/init.d/mysql start" >> /scripts/move-mysql.sh && \
    chmod +x /scripts/move-mysql.sh && \
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
    echo "Install R" && \
    echo "#! /bin/sh" > /scripts/install-r.sh && \
    echo "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9" >> /scripts/install-r.sh && \
    echo "add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'" >> /scripts/install-r.sh && \
    echo "apt-get update" >> /scripts/install-r.sh && \
    echo "apt-get -y install r-base" >> /scripts/install-r.sh && \
    chmod +x /scripts/install-r.sh && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "" > /scripts/notes.txt && \
    echo "R and Matplotlib for Python 2 could not be installed during the building of the docker image" >> /scripts/notes.txt && \
    echo "because it prompts for a region and time zone, and I cannot figure out how to script" >> /scripts/notes.txt && \
    echo "default answers. So if you need either of these then run the corresponding install.sh for it in the /scripts folder" >> /scripts/notes.txt && \
    echo "" >> /scripts/notes.txt && \
    echo "I cannot automate some things during the build, but I can pull the image, manually do some things and push" >> /scripts/notes.txt && \
    echo "the image back so they are done. It's time consuming but if I do that, I will indicate here in the notes which" >> /scripts/notes.txt && \
    echo "steps I have done. I will likely move the MySQL database, install matplotlib and R." >> /scripts/notes.txt && \
	echo "# Final Cleanup" && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "*************" 

RUN echo "*************" && \
    echo "" >> /scripts/notes.txt

ENV JAVA_HOME /usr
ENV PATH $PATH:$JAVA_HOME/bin:/scripts:/home

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

