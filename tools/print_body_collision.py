player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i in range(4135, 4205):
    print(f"L{i+1}: {lines[i]}", end='')
