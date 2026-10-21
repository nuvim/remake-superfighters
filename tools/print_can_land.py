player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'function CanLandInMid' in l:
        for j in range(i, i + 35):
            print(f"L{j+1}: {lines[j]}", end='')
        break
