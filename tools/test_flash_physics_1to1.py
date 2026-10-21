# Point-in-polygon and point-in-box test for Flash Superfighters 1:1 collision

def point_in_poly(x, y, verts):
    # Ray-casting algorithm
    inside = False
    n = len(verts)
    p1x, p1y = verts[0]
    for i in range(n + 1):
        p2x, p2y = verts[i % n]
        if y > min(p1y, p2y):
            if y <= max(p1y, p2y):
                if x <= max(p1x, p2x):
                    if p1y != p2y:
                        xinters = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
                    if p1x == p2x or x <= xinters:
                        inside = not inside
        p1x, p1y = p2x, p2y
    return inside

class FlashWorld:
    def __init__(self):
        # Boxes
        self.boxes = [
            (176.5, 26.5, 351, 51),
            (431, 41.5, 184, 81),
            (345, 94, 12, 24),
            (495, 99.5, 56, 35),
            (411.5, 147, 145, 12),
            (503.5, 153, 39, 72),
            (495, 259, 56, 140),
            (475.5, 159, 17, 12),
            (27.5, 190.5, 53, 277),
            (104.5, 120, 73, 18),
            (90.5, 292, 73, 74),
            (230.5, 301, 147, 56),
            (400.5, 292, 133, 74),
        ]
        # Polygons: stair02 (center 143, 294) and stair01 (center 320, 292)
        # In AS3: MapPremadeItems.IncreaseCorners adds/subtracts 0.5/30 (=0.5px) to corners!
        self.polys = [
            # stair02
            [
                (143 - 16, 294 - 39), # (127, 255)
                (143 - 10, 294 - 39), # (133, 255)
                (143 + 14, 294 - 21), # (157, 273)
                (143 + 14, 294 + 35), # (157, 329)
                (143 - 16, 294 + 35)  # (127, 329)
            ],
            # stair01
            [
                (320 - 16, 292 - 19), # (304, 273)
                (320 + 8, 292 - 37),  # (328, 255)
                (320 + 14, 292 - 37), # (334, 255)
                (320 + 14, 292 + 37), # (334, 329)
                (320 - 16, 292 + 37)  # (304, 329)
            ]
        ]
        
        # Cloud platforms
        self.clouds = [
            (246, 145, 102, 2),
            (197, 167, 50, 2),
            (105, 184, 102, 2),
            (221.5, 208, 93, 2),
            (221.5, 230, 93, 2),
            (221.5, 252, 93, 2),
            (392.5, 212, 93, 2),
            (392.5, 234, 93, 2),
            (423, 190, 88, 2),
        ]

    def hit_test_world(self, x, y):
        # Check boxes
        for (bx, by, bw, bh) in self.boxes:
            min_x = bx - bw / 2 - 0.25 # increaseCorners / width expansion
            max_x = bx + bw / 2 + 0.25
            min_y = by - bh / 2 - 0.25
            max_y = by + bh / 2 + 0.25
            if min_x <= x <= max_x and min_y <= y <= max_y:
                return True
        # Check polys
        for poly in self.polys:
            if point_in_poly(x, y, poly):
                return True
        return False

    def hit_test_cloud(self, x, y):
        for (bx, by, bw, bh) in self.clouds:
            min_x = bx - bw / 2
            max_x = bx + bw / 2
            min_y = by - bh / 2
            max_y = by + bh / 2 + 1
            if min_x <= x <= max_x and min_y <= y <= max_y:
                return True
        return False

world = FlashWorld()

class FlashPlayerSim:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.on_ground = True
        self.jumping = False
        self.player_edge_distance = 6
        self.player_height = 18

    def walk_collision(self, dir_x):
        loc3 = 2
        while loc3 <= 4:
            if world.hit_test_world(self.x + (loc3 - 1) * dir_x, self.y - 2 - loc3):
                return True
            loc3 += 2
        return False

    def collision_feet_mid(self, offset_y=0, offset_x=0):
        if world.hit_test_cloud(self.x, self.y + offset_y):
            return True
        if world.hit_test_world(self.x, self.y + offset_y):
            return True
        if offset_x != 0:
            if world.hit_test_cloud(self.x + offset_x, self.y + offset_y) or world.hit_test_cloud(self.x - offset_x, self.y + offset_y):
                return True
            if world.hit_test_world(self.x + offset_x, self.y + offset_y) or world.hit_test_world(self.x - offset_x, self.y + offset_y):
                return True
        return False

    def can_land_in_mid(self):
        loc1 = 0
        while loc1 <= self.player_edge_distance:
            if world.hit_test_cloud(self.x, self.y + loc1) or world.hit_test_world(self.x, self.y + loc1):
                return True
            loc1 += 2
        return False

    def collision_feet_sides(self):
        loc3 = 2
        while loc3 <= self.player_edge_distance:
            if world.hit_test_world(self.x - loc3, self.y) or world.hit_test_world(self.x + loc3, self.y):
                return True
            loc3 += 2
        return False

    def update_simple_ground_movement(self):
        if self.collision_feet_mid(0, 1):
            if self.collision_feet_mid(-1, 1):
                loc2 = 0
                while self.collision_feet_mid(-1, 1) and loc2 < 100:
                    self.y -= 0.1
                    loc2 += 1
                if loc2 > 0:
                    self.y += 0.1
        elif self.can_land_in_mid():
            if self.on_ground:
                while not self.collision_feet_mid():
                    self.y += 0.1
        elif self.collision_feet_sides():
            pass
        else:
            self.on_ground = False
            self.jumping = True

    def move_player(self, dir_x, speed):
        steps = int(abs(speed * 10))
        step_dx = dir_x * 0.1
        for s in range(steps):
            if self.walk_collision(dir_x):
                return False
            self.x += step_dx
            if self.on_ground:
                self.update_simple_ground_movement()
        return True

print("=== Test 1: Walk RIGHT from x=60 to x=400 (down stair02, across floor, up stair01) ===")
p = FlashPlayerSim(60, 255)
all_grounded = True
for tick in range(250):
    ok = p.move_player(1, 1.7)
    if not p.on_ground:
        all_grounded = False
        print(f"LOST GROUND at tick {tick}: x={p.x:.2f}, y={p.y:.2f}")
        break

print(f"Finished at x={p.x:.2f}, y={p.y:.2f}, on_ground={p.on_ground}")
assert all_grounded and p.x > 380, f"Failed: x={p.x}, y={p.y}"
print("TEST 1 PASSED! Billy walked right smoothly from 60 to 400!")

print("\n=== Test 2: Walk LEFT from x=400 back to x=60 (down stair01, across floor, up stair02) ===")
p2 = FlashPlayerSim(400, 255)
all_grounded2 = True
for tick in range(250):
    ok = p2.move_player(-1, 1.7)
    if not p2.on_ground:
        all_grounded2 = False
        print(f"LOST GROUND at tick {tick}: x={p2.x:.2f}, y={p2.y:.2f}")
        break

print(f"Finished at x={p2.x:.2f}, y={p2.y:.2f}, on_ground={p2.on_ground}")
assert all_grounded2 and p2.x < 80, f"Failed: x={p2.x}, y={p2.y}"
print("TEST 2 PASSED! Billy walked left smoothly from 400 to 60!")
