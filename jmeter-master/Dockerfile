FROM openjdk:11-jre-slim

ENV JMETER_VERSION=5.5
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV PATH=${JMETER_HOME}/bin:${PATH}

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip curl && \
    rm -rf /var/lib/apt/lists/*

# Download and install JMeter
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    rm apache-jmeter-${JMETER_VERSION}.tgz

# Configure JMeter for high load
RUN echo "server.rmi.ssl.disable=true" >> ${JMETER_HOME}/bin/jmeter.properties && \
    echo "java.rmi.server.hostname=\${__P(java.rmi.server.hostname,localhost)}" >> ${JMETER_HOME}/bin/jmeter.properties

# Install JMeter plugins for better reporting
RUN wget https://jmeter-plugins.org/get/ -O ${JMETER_HOME}/lib/ext/jmeter-plugins-manager.jar
RUN wget https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar -O ${JMETER_HOME}/lib/cmdrunner-2.2.jar

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${JMETER_HOME}
EXPOSE 60000
ENTRYPOINT ["/entrypoint.sh"]