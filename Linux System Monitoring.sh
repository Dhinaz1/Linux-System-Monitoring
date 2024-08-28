#!/bin/bash

# Define thresholds
CPU_THRESHOLD=80           # CPU usage threshold in percentage
MEMORY_THRESHOLD=80        # Memory usage threshold in percentage
DISK_THRESHOLD=90          # Disk usage threshold in percentage
NETWORK_THRESHOLD_IN=1000  # Network incoming traffic threshold in KB/s
NETWORK_THRESHOLD_OUT=1000 # Network outgoing traffic threshold in KB/s

# Define email parameters
TO="admin@example.com"
FROM="server@example.com"

# Log file location
LOG_FILE="/var/log/system_monitor.log"

# Function to send email alerts
send_alert() {
    SUBJECT="$1"
    MESSAGE="$2"
    echo "$MESSAGE" | mail -s "$SUBJECT" -r "$FROM" "$TO"
}

# CPU Usage Monitoring
CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {print 100-$NF}')
CPU_ALERT=$(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc)
if [ "$CPU_ALERT" -eq 1 ]; then
    send_alert "CPU Usage Alert" "CPU usage is at ${CPU_USAGE}% which is above the threshold of ${CPU_THRESHOLD}%."
fi

# Memory Usage Monitoring
MEMORY_USAGE=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')
MEMORY_ALERT=$(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc)
if [ "$MEMORY_ALERT" -eq 1 ]; then
    send_alert "Memory Usage Alert" "Memory usage is at ${MEMORY_USAGE}% which is above the threshold of ${MEMORY_THRESHOLD}%."
fi

# Disk Usage Monitoring
DISK_USAGE=$(df -h | awk '$NF=="/"{print $5}' | sed 's/%//')
DISK_ALERT=$(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc)
if [ "$DISK_ALERT" -eq 1 ]; then
    send_alert "Disk Usage Alert" "Disk usage is at ${DISK_USAGE}% which is above the threshold of ${DISK_THRESHOLD}%."
fi

# Network Activity Monitoring
# Replace 'ens33' with your actual network interface name
NETWORK_USAGE=$(ifstat -t 1 1 | awk '/ens33/ {print $6" "$8}')
NETWORK_IN=$(echo "$NETWORK_USAGE" | awk '{print $1}')
NETWORK_OUT=$(echo "$NETWORK_USAGE" | awk '{print $2}')

NETWORK_IN_ALERT=$(echo "$NETWORK_IN > $NETWORK_THRESHOLD_IN" | bc)
NETWORK_OUT_ALERT=$(echo "$NETWORK_OUT > $NETWORK_THRESHOLD_OUT" | bc)

if [ "$NETWORK_IN_ALERT" -eq 1 ]; then
    send_alert "Network Incoming Traffic Alert" "Incoming network traffic is at ${NETWORK_IN}KB/s which is above the threshold of ${NETWORK_THRESHOLD_IN}KB/s."
fi

if [ "$NETWORK_OUT_ALERT" -eq 1 ]; then
    send_alert "Network Outgoing Traffic Alert" "Outgoing network traffic is at ${NETWORK_OUT}KB/s which is above the threshold of ${NETWORK_THRESHOLD_OUT}KB/s."
fi

# Logging the monitoring results
echo "$(date) - CPU: ${CPU_USAGE}%, Memory: ${MEMORY_USAGE}%, Disk: ${DISK_USAGE}%, Network: In: ${NETWORK_IN}KB/s, Out: ${NETWORK_OUT}KB/s" >> $LOG_FILE

echo "System monitoring completed and logged at $(date)"
