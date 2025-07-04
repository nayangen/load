FROM openjdk:11-jre-slim

ENV JMETER_VERSION=5.5
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV PATH=${JMETER_HOME}/bin:${PATH}

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Download and install JMeter
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    rm apache-jmeter-${JMETER_VERSION}.tgz

# Configure JMeter for high load and distributed testing
RUN echo "server.rmi.ssl.disable=true" >> ${JMETER_HOME}/bin/jmeter.properties && \
    echo "java.rmi.server.hostname=\${__P(java.rmi.server.hostname,localhost)}" >> ${JMETER_HOME}/bin/jmeter.properties

# Increase heap size for high load
ENV JVM_ARGS="-Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=100"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${JMETER_HOME}
EXPOSE 1099
ENTRYPOINT ["/entrypoint.sh"]