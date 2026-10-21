map_items = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Handler\MapPremadeItems.as"

with open(map_items, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

def print_range(start, end):
    for i in range(start - 1, end):
        print(f"L{i+1}: {lines[i]}", end='')

print("=== Crate Creation ===")
print_range(1680, 1750)

print("\n=== Barrel Creation ===")
print_range(1960, 2030)
