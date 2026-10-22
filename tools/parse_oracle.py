import re

log_file = "tools/oracle_run.log"

hmw = {}
hmc = {}
hml = {}
ticks = []

with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "avm_trace" not in line:
            continue
        # extract trace text after "avm_trace : "
        parts = line.split("avm_trace")
        if len(parts) < 2:
            continue
        msg = parts[1]
        # clean ansi escape codes
        msg = re.sub(r'\x1b\[[0-9;]*m', '', msg)
        msg = msg.lstrip(": \t\r\n").rstrip()
        
        if msg.startswith("HMW,"):
            tokens = msg.split(",")
            y = int(tokens[1])
            hmw[y] = tokens[2]
        elif msg.startswith("HMC,"):
            tokens = msg.split(",")
            y = int(tokens[1])
            hmc[y] = tokens[2]
        elif msg.startswith("HML,"):
            tokens = msg.split(",")
            y = int(tokens[1])
            hml[y] = tokens[2]
        elif msg.startswith("T,"):
            ticks.append(msg)
        elif "START_HITMAP" in msg or "END_HITMAP" in msg:
            print("MARKER:", msg)

print(f"Total HMW rows: {len(hmw)} (expected 760 from -60 to 699)")
if hmw:
    print(f"HMW range: min Y={min(hmw.keys())}, max Y={max(hmw.keys())}")
print(f"Total HMC rows: {len(hmc)}")
if hmc:
    print(f"HMC range: min Y={min(hmc.keys())}, max Y={max(hmc.keys())}")
print(f"Total HML rows: {len(hml)}")
if hml:
    print(f"HML range: min Y={min(hml.keys())}, max Y={max(hml.keys())}")
print(f"Total Ticks captured: {len(ticks)}")
import os
import json

out_dir = os.path.abspath("superfighters-web/tests/golden")
os.makedirs(out_dir, exist_ok=True)

# 1. Write hitmap_world.txt
with open(os.path.join(out_dir, "hitmap_world.txt"), "w", encoding="utf-8") as f:
    for y in range(-60, 700):
        if y in hmw:
            f.write(f"{y}:{hmw[y]}\n")
print(f"Saved hitmap_world.txt ({os.path.getsize(os.path.join(out_dir, 'hitmap_world.txt'))} bytes)")

# 2. Write hitmap_cloud.txt
with open(os.path.join(out_dir, "hitmap_cloud.txt"), "w", encoding="utf-8") as f:
    for y in range(-60, 700):
        if y in hmc:
            f.write(f"{y}:{hmc[y]}\n")
print(f"Saved hitmap_cloud.txt ({os.path.getsize(os.path.join(out_dir, 'hitmap_cloud.txt'))} bytes)")

# 3. Write hitmap_ladder.txt
with open(os.path.join(out_dir, "hitmap_ladder.txt"), "w", encoding="utf-8") as f:
    for y in range(-60, 700):
        if y in hml:
            f.write(f"{y}:{hml[y]}\n")
print(f"Saved hitmap_ladder.txt ({os.path.getsize(os.path.join(out_dir, 'hitmap_ladder.txt'))} bytes)")

# 4. Write player_trace_idle.json
parsed_ticks = []
for t in ticks:
    parts = t.split(",")
    parsed_ticks.append({
        "tick": int(parts[1]),
        "x": float(parts[2]),
        "y": float(parts[3]),
        "airVelX": float(parts[4]),
        "airVelY": float(parts[5]),
        "onGround": parts[6] == "1",
        "jumping": parts[7] == "1",
        "falling": parts[8] == "1"
    })

with open(os.path.join(out_dir, "player_trace_idle.json"), "w", encoding="utf-8") as f:
    json.dump(parsed_ticks, f, indent=2)
print(f"Saved player_trace_idle.json ({len(parsed_ticks)} ticks)")

