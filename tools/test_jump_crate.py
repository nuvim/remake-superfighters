import math

from test_full_sim import FullFlashWorld, PlayerSim, world

p = PlayerSim(180, 273)
# Walk towards crate at 200
for _ in range(10):
    p.move_player(1, 1.7)

print(f"Before jump: x={p.x:.2f}, y={p.y:.2f}, on_ground={p.on_ground}")

# Jump!
p.jump()
for t in range(25):
    p.move_player(1, 1.7)
    if not p.on_ground:
        p.update_air()
    if p.on_ground:
        print(f"Landed at tick {t}: x={p.x:.2f}, y={p.y:.2f}, on_ground={p.on_ground}")
        break

print(f"After jump: x={p.x:.2f}, y={p.y:.2f}, on_ground={p.on_ground}")
# Top of crate at y=265.5 - 7.5 = 258!
assert p.on_ground and abs(p.y - 258) < 1.0, f"Expected standing on crate around y=258, got y={p.y}"
print("SUCCESSFULLY JUMPED AND STOOD ON TOP OF CRATE!")
