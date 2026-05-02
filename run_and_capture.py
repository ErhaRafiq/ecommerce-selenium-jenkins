import subprocess

# Start server
server_process = subprocess.Popen(["python", "application.py"])

try:
    # Run tests
    import time
    time.sleep(3)
    result = subprocess.run(["python", "-m", "unittest", "test_ecommerce.py"], capture_output=True, text=True)
    with open("test_output.txt", "w") as f:
        f.write(result.stdout)
        f.write(result.stderr)
finally:
    server_process.terminate()
