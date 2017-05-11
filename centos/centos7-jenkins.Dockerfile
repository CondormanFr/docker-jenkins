FROM flyceek/centos7-openjdk:latest
MAINTAINER rgouyet <romain@gouyet.com>

ARG JENKINS_USER=jenkins
ENV JENKINS_USER_HOME=/var/jenkins
ARG JENKINS_USER_PWD=jenkins
ARG JENKINS_USER_GROUP=jenkins
ARG JENKINS_USER_UID=1069
ARG JENKINS_USER_GID=1069

ARG JENKINS_VERSION=2.46.2
ARG JENKINS_FILE_NAME=jenkins-war-${JENKINS_VERSION}.war
ARG JENKINS_FILE_SHA=b91fa09838342980f56224adcf5f02edf668d834
ARG JENKINS_FILE_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/${JENKINS_FILE_NAME}

ENV JENKINS_HTTP_PORT=8080
ENV JENKINS_OPTIONS='--httpPort=${JENKINS_HTTP_PORT}'
ENV JENKINS_JAVA_OPTIONS='-Xmx512m'

WORKDIR ${JENKINS_USER_HOME}
RUN yum update -y \
    && yum install -y sudo git \
    && yum install -y sudo mercurial \
    && yum clean all \
    && { \
        addgroup -g ${JENKINS_USER_GID} ${JENKINS_USER_GROUP}; \
        adduser -h "${JENKINS_USER_HOME}" -u ${JENKINS_USER_UID} -G ${JENKINS_USER_GID} -s /bin/bash -D ${JENKINS_USERuser}; \
        usermod -aG wheel ${JENKINS_USER}; \
        chmod a+w /etc/sudoers; \
        echo "${JENKINS_USER} ALL=(ALL) ALL" >> /etc/sudoers; \
        chown -R ${JENKINS_USER} "${JENKINS_USER_HOME}"; \
        echo "${JENKINS_USER}:${JENKINS_USER_PWD}" | chpasswd; \
        chmod a-w /etc/sudoers; \
    } \
    && curl -O ${JENKINS_FILE_URL} \
    && echo "${JENKINS_FILE_SHA} ${JENKINS_FILE_NAME}" | sha1sum -c - \
    && { \
		echo '#!/bin/sh'; \
		echo 'java ${JENKINS_JAVA_OPTIONS} -jar ${JENKINS_FILE_NAME} ${JENKINS_OPTIONS}'; \
	} > /usr/local/bin/jenkins-start \
    && chmod +x /usr/local/bin/jenkins-start

VOLUME ${JENKINS_USER_HOME}
#USER ${JENKINS_USER}
EXPOSE ${JENKINS_HTTP_PORT}
CMD ["sh","jenkins-start"]
