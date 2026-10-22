import json

walk_golden = json.load(open("superfighters-web/tests/golden/scenario_walk_right.json"))
print(f"Total golden ticks: {len(walk_golden)}")

# Look at y changes along the stair
for i in range(len(walk_golden)):
    g = walk_golden[i]
    if g['y'] != 254.5 and i < 20:
        print(f"Tick {g['tick']}: x={g['x']:.2f}, y={g['y']:.3f}")
