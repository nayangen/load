#!/bin/bash

JMETER_HOME="/opt/apache-jmeter-5.5"

# Start JMeter server in slave mode
exec ${JMETER_HOME}/bin/jmeter-server \
    -Djava.rmi.server.hostname=$(hostname -i) \
    -Dserver.rmi.ssl.disable=true \
    -Djava.rmi.server.useCodebaseOnly=false \
    "$@"