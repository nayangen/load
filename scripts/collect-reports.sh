#!/bin/bash

STACK_NAME="jmeter-load-test"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_DIR="./reports_$TIMESTAMP"

echo "📊 Collecting test reports..."

# Create report directory
mkdir -p $REPORT_DIR

# Get master container ID
MASTER_CONTAINER=$(docker ps --filter "name=${STACK_NAME}_jmeter-master" --format "{{.ID}}" | head -1)

if [ -z "$MASTER_CONTAINER" ]; then
    echo "❌ Master container not found"
    exit 1
fi

# Copy reports from master container
echo "📁 Copying reports from master container..."
docker cp $MASTER_CONTAINER:/reports/. $REPORT_DIR/

# Generate RPM report
echo "📈 Generating RPM analysis..."
cat > $REPORT_DIR/rpm_analysis.py << 'EOF'
import csv
import sys
from datetime import datetime
from collections import defaultdict

def analyze_rpm(jtl_file):
    minute_counts = defaultdict(int)
    
    with open(jtl_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            timestamp = int(row['timeStamp']) // 1000  # Convert to seconds
            minute = timestamp // 60  # Group by minute
            minute_counts[minute] += 1
    
    print("=== RPM Analysis ===")
    print(f"{'Minute':<10} {'Requests':<10} {'RPM':<10}")
    print("-" * 30)
    
    total_requests = 0
    for minute in sorted(minute_counts.keys()):
        requests = minute_counts[minute]
        total_requests += requests
        print(f"{minute:<10} {requests:<10} {requests:<10}")
    
    avg_rpm = total_requests / len(minute_counts) if minute_counts else 0
    max_rpm = max(minute_counts.values()) if minute_counts else 0
    
    print("-" * 30)
    print(f"Average RPM: {avg_rpm:.2f}")
    print(f"Maximum RPM: {max_rpm}")
    print(f"Total Requests: {total_requests}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        analyze_rpm(sys.argv[1])
    else:
        print("Usage: python rpm_analysis.py <jtl_file>")
EOF

# Run RPM analysis if results file exists
if [ -f "$REPORT_DIR/results.jtl" ]; then
    python3 $REPORT_DIR/rpm_analysis.py $REPORT_DIR/results.jtl > $REPORT_DIR/rpm_summary.txt
    echo "📊 RPM analysis saved to: $REPORT_DIR/rpm_summary.txt"
fi

echo "✅ Reports collected in: $REPORT_DIR"
echo "🌐 Open $REPORT_DIR/html/index.html for detailed HTML report"