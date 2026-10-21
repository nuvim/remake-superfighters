from test_full_sim import FullFlashWorld

world = FullFlashWorld()

x = 136.5
y = 255.0

print(f"Initial at x={x}, y={y}")
print("hitTestWorld(x, y):", world.hit_test_world(x, y))

# CanLandInMid:
can_land = False
for loc1 in [0, 2, 4, 6]:
    if world.hit_test_world(x, y + loc1):
        print(f"canLandInMid hit at loc1={loc1}, y={y+loc1}")
        can_land = True
        break

print("can_land:", can_land)

# while not collisionFeetMid(): y += 0.1
steps = 0
while not world.hit_test_world(x, y) and steps < 100:
    y += 0.1
    steps += 1

print(f"After while: steps={steps}, y={y:.2f}, hit={world.hit_test_world(x, y)}")
