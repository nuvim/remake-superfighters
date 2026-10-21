map_items = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Handler\MapPremadeItems.as"

with open(map_items, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'case "CRATE":' in l or 'case "BARREL":' in l or 'case "BARREL_EXPLOSIVE":' in l:
        print(f"Found at L{i+1}: {l.strip()}")
        for j in range(i, min(i + 35, len(lines))):
            print(f"L{j+1}: {lines[j]}", end='')
        print("-" * 50)
