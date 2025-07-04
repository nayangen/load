# Quick Start:

```
# 1. Build the images first
docker build -t jmeter-master:latest ./jmeter-master
docker build -t jmeter-slave:latest ./jmeter-slave

# 2. Verify images exist
docker images | grep jmeter

# 3. Deploy the stack
SLAVE_COUNT=10 docker stack deploy -c docker-compose.yml jmeter-load-test

# 2. Run your test
docker service update \
  --env-add TEST_PLAN=load-test.jmx \
  --env-add target_host=your-backend.com \
  jmeter-load-test_jmeter-master

# 3. Collect RPM reports
./scripts/collect-reports.sh
```