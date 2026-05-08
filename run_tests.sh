#!/bin/bash

export PYTHONUNBUFFERED=1

FLASK_PID=""

if [ -z "$APP_URL" ]; then
    export APP_URL="http://127.0.0.1:5000"

    echo "No APP_URL provided. Starting Flask server inside test container..."
    python application.py &
    FLASK_PID=$!
else
    echo "APP_URL provided. Testing already deployed app at: $APP_URL"
fi

echo "Waiting for app to become reachable..."

python - <<'PY'
import os
import time
import urllib.request
import sys

url = os.environ.get("APP_URL", "http://127.0.0.1:5000")

for i in range(12):
    try:
        urllib.request.urlopen(url, timeout=3)
        print("App is reachable!")
        sys.exit(0)
    except Exception as e:
        print(f"Attempt {i+1}/12 failed. Waiting 5 seconds...")
        time.sleep(5)

print("App did not become reachable.")
sys.exit(1)
PY

echo "Running Selenium tests..."
python -u -m unittest -v test_ecommerce.py
TEST_EXIT_CODE=$?

if [ -n "$FLASK_PID" ]; then
    echo "Stopping Flask server..."
    kill "$FLASK_PID" || true
fi

exit $TEST_EXIT_CODE
