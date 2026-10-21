items_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Handler\MapPremadeItems.as"

with open(items_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i in range(435, 485):
    print(f"L{i+1}: {lines[i]}", end='')
