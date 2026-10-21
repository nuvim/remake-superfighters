player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

def print_fn(name, start_l, end_l):
    print(f"=== {name} (L{start_l}-L{end_l}) ===")
    for i in range(start_l - 1, end_l):
        print(f"L{i+1}: {lines[i]}", end='')
    print()

print_fn("MoveDirection", 3812, 3880)
print_fn("UpdateObjectImpacts", 3934, 4000)
print_fn("UpdateDynamicMovement", 5953, 6050)
