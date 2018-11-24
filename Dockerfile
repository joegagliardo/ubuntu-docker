# joegagliardo/ubuntu
# if building locally use this to save time
# FROM joegagliardo/ubuntu-base
# otherwise use this when building on hub.docker.com
FROM ubuntu:18.10
MAINTAINER joegagliardo

USER root
ARG DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# MYSQL Passwords
ARG MYSQLROOT_PASSWORD=rootpassword
ARG MYSQL_PASSWORD=

# Versions
ARG JULIA_VERSION=1.0.2
ARG JULIA_BASE_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.0
ARG JULIA_FILE=julia-${JULIA_VERSION}-linux-x86_64.tar.gz
ARG JULIA_URL=${JULIA_BASE_URL}/${JULIA_FILE}

ARG PIP_URL=https://bootstrap.pypa.io/get-pip.py

# needed for R
ARG LIBPNG_URL=http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb

ADD downloads/foo downloads/${JULIA_FILE}* /usr/local/
ADD scripts /scripts

# Install Dev Tools & Java
RUN echo "# ---------------------------------------------" && \
    echo "# Environment" && \
    echo "# ---------------------------------------------" && \
    mkdir /data && \
    echo "# needed to stop the error message for matplotlib" && \
    sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
    echo "# ---------------------------------------------" && \
    echo "# OS Tools" && \
    echo "# ---------------------------------------------" && \
    apt-get update && \
    apt-get -y install curl tar sudo openssh-server openssh-client unzip rsync nano vim software-properties-common git gcc apt-utils netcat debconf apt-transport-https net-tools libaio-dev aptitude libgmp3-dev libmysqlclient-dev python2.7 python2.7-dev python3.7 python3.7-dev python-pip python3-pip clang libicu-dev && \
    apk --no-cache --update-cache add gcc gfortran python python-dev py-pip build-base wget freetype-dev libpng-dev openblas-dev && \
    echo "# ---------------------------------------------" && \
    echo "# Python 2" && \
    echo "# ---------------------------------------------" && \
    pip2 install numpy scipy pandas cherrypy pymysql pymssql sklearn py4j matplotlib && \
    pip2 install pyspark && \
    echo "# ---------------------------------------------" && \
    echo "# Python 3" && \
    echo "# ---------------------------------------------" && \
    pip3 install numpy scipy pandas cherrypy pymysql pymssql sklearn py4j matplotlib && \
    pip3 install --no-cache-dir pyspark && \
    echo "# ---------------------------------------------" && \
    echo "# Java repository" && \
    echo "# ---------------------------------------------" && \
    add-apt-repository ppa:webupd8team/java -y && \
    echo "# ---------------------------------------------" && \
    echo "# SBT repository" && \
    echo "# ---------------------------------------------" && \
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    echo "# ---------------------------------------------" && \
    echo "# R repository" && \
    echo "# ---------------------------------------------" && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
    apt-get update && \
    echo "# ---------------------------------------------" && \
    echo "# Java Maven Scala SBT NodeJS NPM Sqlite3" && \
    echo "# ---------------------------------------------" && \
    apt-get install -y openjdk-11-jdk build-essential maven scala sbt nodejs npm sqlite3 libsqlite3-dev && \
    echo "# ---------------------------------------------" && \
    echo "# Julia" && \
    echo ${JULIA_URL} && \
    echo "# ---------------------------------------------" && \
    cd /tmp && \
    test ! -e /usr/local/julia* && curl -s ${JULIA_URL} | tar -xz -C /usr/local/ || echo "Julia exists" && \
    ln -s /usr/local/julia* /usr/local/julia && \
    echo "" && \
    echo "# ---------------------------------------------" && \
    echo "# R" && \
    echo "# ---------------------------------------------" && \
    cd /home && \
    wget ${LIBPNG_URL} && \
    dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb && \
    rm /home/* && \
    apt-get -y install gdebi libxml2-dev libssl-dev libcurl4-openssl-dev libopenblas-dev && \
    aptitude install -y r-cran-spatial r-cran-boot r-recommended r-base-core r-base r-base-html && \
    echo "# ---------------------------------------------" && \
    echo "# MYSQL" && \
    echo "# ---------------------------------------------" && \
	echo "mysql-server mysql-server/root_password password ${MYSQLROOT_PASSWORD}" | debconf-set-selections && \
	echo "mysql-server mysql-server/root_password_again password ${MYSQLROOT_PASSWORD}" | debconf-set-selections && \
    apt-get -y install mysql-server mysql-client libmysql-java && \
    mkdir /data/mysql && \
    echo "[client]" > /etc/my.cnf && \
    echo "user=root" >> /etc/my.cnf && \
    echo "password=${MYSQLROOT_PASSWORD}" >> /etc/my.cnf && \
    echo "" >> /etc/my.cnf && \
    echo "[mysqld]" >> /etc/my.cnf && \
    echo "datadir=/data/mysql" >> /etc/my.cnf && \
    mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql --explicit_defaults_for_timestamp && \
    usermod -d /data/mysql/ mysql && \
    echo "#! /bin/sh" > /scripts/start-mysql.sh && \
    echo "# weird problem about starting MySQL in a container so I found this article: https://github.com/moby/moby/issues/34390" && \
    echo "find /var/lib/mysql/mysql -exec touch -c -a {} + && service mysql start" >> /scripts/start-mysql.sh && \
    chmod +x /scripts/start-mysql.sh && \
    echo "#! /bin/sh" > /scripts/stop-mysql.sh && \
    echo "/etc/init.d/mysql stop" >> /scripts/stop-mysql.sh && \
    chmod +x /scripts/stop-mysql.sh && \
    echo "# ---------------------------------------------" && \
    echo "# Notes" && \
    echo "# ---------------------------------------------" && \
    echo "alias hist='f(){ history | grep \"\$1\";  unset -f f; }; f'" >> ~/.bashrc && \
    echo "Installation Notes" > /scripts/notes.txt && \
    echo "" >> /scripts/notes.txt && \
    echo "# ---------------------------------------------" && \
	echo "# Final Cleanup" && \
    echo "# ---------------------------------------------" && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "# ---------------------------------------------" && \
	echo "# Done" && \
    echo "# ---------------------------------------------"

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $PATH:/usr/local/julia/bin:$JAVA_HOME/bin:/scripts:/host:/home

#    echo "# ---------------------------------------------" && \
#    echo "# MatPlotLib" && \
#    echo "# ---------------------------------------------" && \
#    apt-get -yq --fix-missing build-dep python-matplotlib && \
#    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \


#    echo "# ---------------------------------------------" && \
#    echo "# Julia" && \
#    echo ${JULIA_URL} && \
#    echo "# ---------------------------------------------" && \
#    curl -s ${JULIA_URL} | tar -xz -C /usr/local/ && \    
#    ln -s /usr/local/julia* /usr/local/julia && \

# Old stuff but most have been converted to apt-get installs now
# 2018-01-19 removed R but need to fix.
#    echo "# ---------------------------------------------" && \
#    echo "# R" && \
#   echo "# ---------------------------------------------" && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
#    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
#    apt-get update && \
#    cd /home && \
#    wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb && \
#    dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y install gdebi libxml2-dev libssl-dev libcurl4-openssl-dev libopenblas-dev && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y install r-base r-base-core r-recommended r-base-html && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y install r-base-core && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y install r-cran-boot && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y install r-cran-spatial && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y r-base r-recommended r-base-html && \



#    echo "# ---------------------------------------------" && \
#    echo "# Scala" && \
#    echo "# ---------------------------------------------" && \
#    echo ${SCALA_URL} && \
#    cd /home && \
#    wget ${SCALA_URL} && \
#    dpkg -i scala-${SCALA_VERSION}.deb && \
#    rm scala-${SCALA_VERSION}.deb && \
#    echo "# ---------------------------------------------" && \
#    echo "# SBT" && \
#    echo "# ---------------------------------------------" && \
#    echo ${SBT_URL} && \
#    cd /home && \
#    wget ${SBT_URL} && \
#    dpkg -i sbt-${SBT_VERSION}.deb && \
#    cd /home && \
#    apt-get install -f && \
#    rm /home/sbt-${SBT_VERSION}.deb && \

#    echo "# ---------------------------------------------" && \
#    echo "# Maven" && \
#    echo "# ---------------------------------------------" && \
#    echo ${MAVEN_URL} && \ 
#    mkdir -p /usr/share/maven /usr/share/maven/ref && \
#    curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_URL} && \ 
#    echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - && \
#    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 && \
#    rm -f /tmp/apache-maven.tar.gz && \
#    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \



#    echo "Install R" && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
#    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
#	 apt-get update && \
#    apt-get -y install r-base && \


#    echo "# Postgresql" && \
#    DEBIAN_FRONTEND=noninteractive apt-get -yq install postgresql postgresql-contrib postgresql-client && \
#    echo "#! /bin/sh" > /scripts/start-postgresql.sh && \
#    echo "/etc/init.d/postgresql start" >> /scripts/start-postgresql.sh && \
#    chmod +x /scripts/start-postgresql.sh && \
#    echo "#! /bin/sh" > /scripts/postgres-client.sh && \
#    echo "sudo -u postgres psql" >> /scripts/postgres-client.sh && \
#    chmod +x /scripts/postgres-client.sh && \


#chmod 600 /etc/mysql/my.cnf
#chown mysql:mysql /etc/my.cnf
#sudo chown mysql:root /var/lib/mysql/ -R
#sudo chmod g+rw /var/lib/mysql/ -R


#vi /etc/mysql/my.cnf
#You will find the lines below top in your configuration file

#[client]
#port            = 3306
#socket          = /var/run/mysqld/mysqld.sock



#rm -r /data/mysql && \
#    mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql --explicit_defaults_for_timestamp && \
#    sudo chown -R mysql /data/mysql && \
#    sudo chgrp -R mysql /data/mysql && \
#    usermod -d /data/mysql/ mysql
    
#sudo mkdir /var/mysql
#ln -s /tmp/mysql.sock /var/mysql/mysql.sock 

#    ln -s /tmp/mysql.sock /var/mysql/mysql.sock && \
    
#    sudo chown -R mysql /data/mysql && \
#    sudo chgrp -R mysql /data/mysql && \
#    ln -s /usr/bin/python2.7 /usr/bin/python && \
# --name bigdata-client --hostname bigdata
# docker run --name sqlserver --hostname sqlserver -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=SapwAug2017!' --cap-add SYS_PTRACE -p 1433:1433 -v $HOME/Dev/sqlserver-linux:/var/opt/mssql -d microsoft/mssql-server-linux
# docker run --name sqlserver -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=SapwAug2017!' --cap-add SYS_PTRACE -p 1433:1433 -v sqlserver-linux-volume:/var/opt/mssql -d microsoft/mssql-server-linux

# docker run --name sqlserver -v "$HOME:/home" -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Sapw17!Sapw17!' -p 1433:1433 -d microsoft/mssql-server-linux
# docker run --name sqlserver -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=SapwAug2017!' -p 1433:1433 -d microsoft/mssql-server-linux
# docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SapwAug2017!
# docker exec -it sqlserver /bin/bash
# /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SapwAug2017!


# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
# choco install -y docker  
# choco install -y docker-machine  
# choco install -y docker-machine-vmwareworkstation  


#import pymssql
#conn = pymssql.connect(server='sqlserver', user='sa', password='SaPassword17!', database='joey1')
#conn = pymssql.connect(server='172.17.0.2', user='sa', password='SaPassword17!', database='joey1')
#cursor = conn.cursor()
#cursor.execute('select * from names')
#row=cursor.fetchone()
#print row


# docker run --name sqlserver --hostname sqlserver -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=SaPassword17!' --cap-add SYS_PTRACE -p 1433:1433 -v sqlvolume:/var/opt/mssql -d microsoft/mssql-server-linux
# docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SaPassword17!
# docker exec -it sqlserver /bin/bash
# /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SaPassword17!


#    curl --progress-bar https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.1-linux-x86_64.tar.gz | tar -xz -C /usr/local/ && \
# git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch <file/dir>' HEAD

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



#   wget ${PIP_URL} && \
#    echo "----> ln -s /usr/bin/python2.7 /usr/bin/python" && \
#    echo "----> ln -s /usr/bin/python2.7 /usr/bin/python2" && \
#    echo ""
#RUN    python get-pip.py && \
#    echo ""
#RUN  python3 get-pip.py" && \
#    echo ""
#RUN    rm /usr/local/bin/pip && \
#    ln -s /usr/local/bin/pip2 /usr/local/bin/pip && \
#    mv get-pip.py /scripts && \
#    pip2 install --upgrade pip && \
#    pip3 install --upgrade pip && \
#     ln -s /usr/bin/pip /usr/bin/pip2 && \
#    pip2 install matplotlib && \
#    pip3 install matplotlib && \

#    pip3 install numpy && \
#    pip2 install scipy && \
#    pip3 install scipy && \
#    pip2 install pandas && \
#    pip3 install pandas && \
#    pip2 install cherrypy && \
#    pip3 install cherrypy && \
#    pip2 install pymysql && \
#    pip3 install pymysql && \
#    pip2 install pymssql && \
#    pip3 install pymssql && \
#     curl -s ${JULIA_URL} | tar -xz -C /usr/local/ && \    


#    wget ${JULIA_URL} && \
#    tar -xzF /tmp/julia* -C /usr/local && \ 
#    rm /tmp/julia* && \
#     curl -s ${JULIA_URL} | tar -xzM -C /usr/local/ && \    


#    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
#    echo "----> uncomment ----->     apt-get -y install oracle-java8-installer build-essential" && \


#    echo "# ---------------------------------------------" && \
#    echo "# Java" && \
#    echo "# ---------------------------------------------" && \
#    apt-get -y install openjdk-11-jdk build-essential && \
#    echo "# ---------------------------------------------" && \
#    echo "# Maven Scala SBT NodeJS NPM Sqlite3" && \
#    echo "# ---------------------------------------------" && \
#    apt-get -y install maven scala sbt nodejs npm sqlite3 libsqlite3-dev && \
