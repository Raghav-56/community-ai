#!/bin/bash

echo "Starting all services..."

# Start all services in background
python scripts/github_agent.py &
GITHUB_PID=$!

python scripts/jira.py &
JIRA_PID=$!

python scripts/slack.py &
SLACK_PID=$!

echo "All servers started!"
echo "GitHub Agent PID: $GITHUB_PID"
echo "Jira Agent PID: $JIRA_PID"
echo "Slack Agent PID: $SLACK_PID"

# Function to handle shutdown
cleanup() {
    echo "Shutting down services..."
    kill $GITHUB_PID $JIRA_PID $SLACK_PID 2>/dev/null
    wait
    echo "All services stopped"
    exit 0
}

# Trap signals to handle graceful shutdown
trap cleanup SIGTERM SIGINT

# Keep the script running and monitor processes
while true; do
    if ! kill -0 $GITHUB_PID 2>/dev/null; then
        echo "GitHub agent died, restarting..."
        python scripts/github_agent.py &
        GITHUB_PID=$!
    fi
    
    if ! kill -0 $JIRA_PID 2>/dev/null; then
        echo "Jira agent died, restarting..."
        python scripts/jira.py &
        JIRA_PID=$!
    fi
    
    if ! kill -0 $SLACK_PID 2>/dev/null; then
        echo "Slack agent died, restarting..."
        python scripts/slack.py &
        SLACK_PID=$!
    fi
    
    sleep 10
done
