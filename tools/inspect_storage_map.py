maps_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Handler\Maps.as"

with open(maps_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i in range(2345, 2410):
    print(f"L{i+1}: {lines[i]}", end='')
