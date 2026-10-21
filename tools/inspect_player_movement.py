import os
import re

player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

print(f"Total lines in Player.as: {len(lines)}")

# Let's search for functions related to movement, update, walk, run, stair, slope, velocity
patterns = ['function Update', 'function Walk', 'function Move', 'function Run', 'function CheckGround', 'function Collision']
for idx, line in enumerate(lines):
    for p in patterns:
        if p.lower() in line.lower():
            print(f"L{idx+1}: {line.strip()}")
