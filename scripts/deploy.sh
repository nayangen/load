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

# Create directories
mkdir -p reports plans

# Build images
echo "📦 Building Docker images..."
docker build -t jmeter-master:latest ./jmeter-master
docker build -t jmeter-slave:latest ./jmeter-slave

# Verify images exist
echo "🔍 Verifying images..."
if ! docker image inspect jmeter-master:latest >/dev/null 2>&1; then
    echo "❌ jmeter-master image not found"
    exit 1
fi

if ! docker image inspect jmeter-slave:latest >/dev/null 2>&1; then
    echo "❌ jmeter-slave image not found"
    exit 1
fi

echo "✅ Images verified successfully"

# Remove existing stack if it exists
if docker stack ls | grep -q $STACK_NAME; then
    echo "🗑️  Removing existing stack..."
    docker stack rm $STACK_NAME
    echo "⏳ Waiting for stack removal..."
    sleep 30
fi

# Deploy stack
echo "🏗️  Deploying stack..."
SLAVE_COUNT=$SLAVE_COUNT docker stack deploy -c docker-compose.yml $STACK_NAME

echo "⏳ Waiting for services to be ready..."
sleep 60

# Check service status
echo "📊 Service Status:"
docker service ls --filter name=$STACK_NAME

# Wait for all replicas to be ready
echo "⏳ Waiting for all replicas to be ready..."
timeout=300  # 5 minutes timeout
elapsed=0
while [ $elapsed -lt $timeout ]; do
    ready=$(docker service ls --filter name=$STACK_NAME --format "table {{.Replicas}}" | tail -n +2 | grep -v "0/" | wc -l)
    total=$(docker service ls --filter name=$STACK_NAME --format "table {{.Name}}" | tail -n +2 | wc -l)
    
    if [ "$ready" -eq "$total" ] && [ "$total" -gt 0 ]; then
        echo "✅ All services are ready!"
        break
    fi
    
    echo "⏳ Services ready: $ready/$total (waiting...)"
    sleep 10
    elapsed=$((elapsed + 10))
done

if [ $elapsed -ge $timeout ]; then
    echo "⚠️  Timeout waiting for services to be ready"
    echo "📊 Current status:"
    docker service ls --filter name=$STACK_NAME
    echo "🔍 Check logs with: docker service logs ${STACK_NAME}_jmeter-master"
else
    echo "✅ Deployment complete!"
    echo ""
    echo "📈 To run a test:"
    echo "   docker service update --env-add TEST_PLAN=load-test.jmx ${STACK_NAME}_jmeter-master"
    echo ""
    echo "🔍 Monitor with:"
    echo "   docker service logs -f ${STACK_NAME}_jmeter-master"
fi