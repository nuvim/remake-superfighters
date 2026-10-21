player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

def print_fn(name, start_l, end_l):
    print(f"=== {name} (L{start_l}-L{end_l}) ===")
    for i in range(start_l - 1, end_l):
        print(f"L{i+1}: {lines[i]}", end='')
    print()

print_fn("CollisionFeetMid", 8238, 8275)
print_fn("CanLandInMid", 8270, 8320)
print_fn("WorldCollisionHead", 8030, 8070)
print_fn("UpdateAirMovement", 4628, 4710)
