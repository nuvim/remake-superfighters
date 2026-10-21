player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'GetDynamicBodyAt' in l or '_standingOnObject' in l or 'UpdateDynamicMovement' in l:
        print(f"L{i+1}: {l.strip()}")
