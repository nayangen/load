#!/bin/bash

JMETER_HOME="/opt/apache-jmeter-5.5"

# Wait for slaves to be ready
sleep 30

# Get slave IPs from Docker service
SLAVES=$(getent hosts tasks.jmeter-slave | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')

if [ -z "$SLAVES" ]; then
    echo "No slaves found, running in non-distributed mode"
    exec ${JMETER_HOME}/bin/jmeter "$@"
else
    echo "Found slaves: $SLAVES"
    
    # Run distributed test
    if [ -n "$TEST_PLAN" ]; then
        exec ${JMETER_HOME}/bin/jmeter \
            -n \
            -t /test-plans/${TEST_PLAN} \
            -R ${SLAVES} \
            -l /reports/results.jtl \
            -e \
            -o /reports/html \
            -Djava.rmi.server.hostname=$(hostname -i) \
            -Dserver.rmi.ssl.disable=true \
            -Dsummariser.interval=30 \
            "$@"
    else
        # Keep container running for manual testing
        tail -f /dev/null
    fi
fi