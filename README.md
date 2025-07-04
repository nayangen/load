# Quick Start:

```
# 1. Deploy the cluster (10 slaves = 100k RPM capacity)
SLAVE_COUNT=10 ./scripts/deploy.sh

# 2. Run your test
docker service update \
  --env-add TEST_PLAN=load-test.jmx \
  --env-add target_host=your-backend.com \
  jmeter-load-test_jmeter-master

# 3. Collect RPM reports
./scripts/collect-reports.sh
```