import subprocess
import os
import sys

env = os.environ.copy()
env["RUST_LOG"] = "info"

cmd = [
    r"C:\Program Files\ruffle\bin\ruffle.exe",
    "--graphics", "dx12",
    os.path.abspath("tools/oracle_superfighters.swf")
]

log_path = os.path.abspath("tools/oracle_run.log")
print(f"Launching Ruffle, saving output to {log_path}...")

with open(log_path, "w", encoding="utf-8") as out:
    proc = subprocess.Popen(cmd, env=env, stdout=out, stderr=subprocess.STDOUT)
    try:
        proc.wait(timeout=30)
    except subprocess.TimeoutExpired:
        print("30 seconds elapsed, terminating Ruffle...")
        proc.terminate()
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            proc.kill()

print("Ruffle finished. Checking log size...")
if os.path.exists(log_path):
    print(f"Log size: {os.path.getsize(log_path)} bytes")
