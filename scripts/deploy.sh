#!/bin/bash

set -e

# Configuration
SLAVE_COUNT=${SLAVE_COUNT:-10}
STACK_NAME="jmeter-load-test"

echo "🚀 Deploying JMeter Load Test Stack with $SLAVE_COUNT slaves..."

# Initialize Docker Swarm if not already done
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init
fi

# Build images
echo "📦 Building Docker images..."
docker build -t jmeter-master:latest ./jmeter-master
docker build -t jmeter-slave:latest ./jmeter-slave

# Create directories
mkdir -p reports test-plans

# Deploy stack
echo "🏗️  Deploying stack..."
SLAVE_COUNT=$SLAVE_COUNT docker stack deploy -c docker-compose.yml $STACK_NAME

echo "⏳ Waiting for services to be ready..."
sleep 60

# Show status
echo "📊 Service Status:"
docker service ls | grep $STACK_NAME

echo "✅ Deployment complete!"
echo "📈 To run a test:"
echo "   TEST_PLAN=load-test.jmx docker service update --env-add TEST_PLAN=load-test.jmx ${STACK_NAME}_jmeter-master"