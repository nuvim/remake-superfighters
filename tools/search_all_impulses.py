player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'ApplyImpulse' in l or 'applyLinearImpulse' in l or 'SetLinearVelocity' in l:
        print(f"L{i+1}: {l.strip()}")
        for j in range(max(0, i - 5), min(len(lines), i + 6)):
            print(f"  {j+1}: {lines[j].strip()[:80]}")
        print("="*60)
