import math

def point_in_poly(x, y, verts):
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

class FullFlashWorld:
    def __init__(self):
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
        self.polys = [
            # stair02
            [(127, 255), (133, 255), (157, 273), (157, 329), (127, 329)],
            # stair01
            [(304, 273), (328, 255), (334, 255), (334, 329), (304, 329)]
        ]
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
        # Dynamic objects: e.g. a crate at x=200, y=265 (sitting on floor at y=273, height=15)
        # top of crate is at y = 273 - 15 = 258!
        self.dynamic_crates = [
            {'x': 200, 'y': 265.5, 'w': 15, 'h': 15}
        ]

    def hit_test_world(self, x, y):
        for (bx, by, bw, bh) in self.boxes:
            min_x = bx - bw / 2 - 0.25
            max_x = bx + bw / 2 + 0.25
            min_y = by - bh / 2 - 0.25
            max_y = by + bh / 2 + 0.25
            if min_x <= x <= max_x and min_y <= y <= max_y:
                return True
        for poly in self.polys:
            if point_in_poly(x, y, poly):
                return True
        for c in self.dynamic_crates:
            min_x = c['x'] - c['w'] / 2
            max_x = c['x'] + c['w'] / 2
            min_y = c['y'] - c['h'] / 2
            max_y = c['y'] + c['h'] / 2
            if min_x <= x <= max_x and min_y <= y <= max_y:
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

world = FullFlashWorld()

class PlayerSim:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.on_ground = True
        self.jumping = False
        self.falling = False
        self.air_vel_y = 0.0
        self.air_vel_x = 0.0
        self.edge_dist = 6
        self.height = 18

    def walk_collision(self, dir_x):
        loc3 = 2
        while loc3 <= 4:
            if world.hit_test_world(self.x + (loc3 - 1) * dir_x, self.y - 2 - loc3):
                return True
            loc3 += 2
        return False

    def collision_side(self, dir_x, dist=6):
        loc3 = 6
        while loc3 <= self.height - 2:
            if world.hit_test_world(self.x + dist * dir_x, self.y - loc3):
                return True
            loc3 += 2
        return False

    def collision_feet_mid(self, offset_y=0, offset_x=0):
        if world.hit_test_cloud(self.x, self.y + offset_y) or world.hit_test_world(self.x, self.y + offset_y):
            return True
        if offset_x != 0:
            if world.hit_test_cloud(self.x + offset_x, self.y + offset_y) or world.hit_test_world(self.x + offset_x, self.y + offset_y):
                return True
            if world.hit_test_cloud(self.x - offset_x, self.y + offset_y) or world.hit_test_world(self.x - offset_x, self.y + offset_y):
                return True
        return False

    def can_land_in_mid(self):
        loc1 = 0
        while loc1 <= self.edge_dist:
            if world.hit_test_cloud(self.x, self.y + loc1) or world.hit_test_world(self.x, self.y + loc1):
                return True
            loc1 += 2
        return False

    def collision_feet_sides(self):
        loc3 = 2
        while loc3 <= self.edge_dist:
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
                # Touch crate or wall -> push dynamic crate if present
                for c in world.dynamic_crates:
                    if abs(self.x + dir_x * self.edge_dist - c['x']) < c['w']:
                        c['x'] += step_dx * 0.5 # push crate
                return False
            self.x += step_dx
            if self.on_ground:
                self.update_simple_ground_movement()
        return True

    def jump(self):
        if self.on_ground:
            self.on_ground = False
            self.jumping = True
            self.air_vel_y = -5.0

    def update_air(self):
        self.air_vel_y += 0.6
        if self.air_vel_y > 0:
            self.jumping = False
            self.falling = True

        total_speed = math.ceil(abs(self.air_vel_y))
        if total_speed < 1:
            total_speed = 1
        step_dy = self.air_vel_y / total_speed
        for s in range(int(total_speed)):
            self.y += step_dy
            if self.air_vel_y > 0:
                if self.collision_feet_sides() and self.can_land_in_mid() and self.collision_feet_mid():
                    # Land!
                    self.on_ground = True
                    self.jumping = False
                    self.falling = False
                    self.air_vel_y = 0.0
                    while not self.collision_feet_mid():
                        self.y += 0.1
                    break

if __name__ == '__main__':
    # TEST 1: Walk from x=70 to x=180
    p = PlayerSim(70, 255)
    for t in range(100):
        p.move_player(1, 1.7)
        if not p.on_ground:
            p.update_air()

    print(f"Reached right: x={p.x:.2f}, y={p.y:.2f}, on_ground={p.on_ground}")
    assert p.x > 180

    for t in range(100):
        p.move_player(-1, 1.7)
        if not p.on_ground:
            p.update_air()

    print(f"Returned left: x={p.x:.2f}, y={p.y:.2f}, on_ground={p.on_ground}")
    assert p.x < 100
    print("ALL TESTS PASSED IN SIMULATION!")
