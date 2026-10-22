import json
import math
import os

idle_golden = json.load(open("superfighters-web/tests/golden/scenario_idle.json"))
walk_golden = json.load(open("superfighters-web/tests/golden/scenario_walk_right.json"))
jump_golden = json.load(open("superfighters-web/tests/golden/scenario_jump_standing.json"))
jump_run_golden = json.load(open("superfighters-web/tests/golden/scenario_jump_run.json"))

print(f"Loaded: idle={len(idle_golden)}, walk={len(walk_golden)}, jump={len(jump_golden)}, jump_run={len(jump_run_golden)}")

# Check jump standing kinematics
print("\n--- JUMP STANDING FLASH GOLDEN (ticks 189..200) ---")
for t in jump_golden:
    if 188 <= t["tick"] <= 200:
        print(f"Tick {t['tick']}: x={t['x']:.2f}, y={t['y']:.3f}, vy={t['airVelY']:.2f}, onGround={t['onGround']}, jumping={t['jumping']}, falling={t['falling']}")

# Check jump run kinematics
print("\n--- JUMP RUN FLASH GOLDEN (ticks 278..290) ---")
for t in jump_run_golden:
    if 278 <= t["tick"] <= 290:
        print(f"Tick {t['tick']}: x={t['x']:.2f}, y={t['y']:.3f}, vy={t['airVelY']:.2f}, onGround={t['onGround']}, jumping={t['jumping']}, falling={t['falling']}")
