# Simulating Player movement in StorageMap as currently implemented in TypeScript

class MockStorageMap:
    def __init__(self):
        # groundBoxes from StorageMap.ts
        self.ground_boxes = [
            {'x': 176.5, 'y': 26.5, 'w': 351, 'h': 51, 'type': 'NONE'},
            {'x': 431, 'y': 41.5, 'w': 184, 'h': 81, 'type': 'NONE'},
            {'x': 345, 'y': 94, 'w': 12, 'h': 24, 'type': 'NONE'},
            {'x': 495, 'y': 99.5, 'w': 56, 'h': 35, 'type': 'NONE'},
            {'x': 411.5, 'y': 147, 'w': 145, 'h': 12, 'type': 'NONE'},
            {'x': 503.5, 'y': 153, 'w': 39, 'h': 72, 'type': 'NONE'},
            {'x': 495, 'y': 259, 'w': 56, 'h': 140, 'type': 'NONE'},
            {'x': 475.5, 'y': 159, 'w': 17, 'h': 12, 'type': 'NONE'},
            {'x': 27.5, 'y': 190.5, 'w': 53, 'h': 277, 'type': 'NONE'},
            {'x': 104.5, 'y': 120, 'w': 73, 'h': 18, 'type': 'NONE'},
            {'x': 90.5, 'y': 292, 'w': 73, 'h': 74, 'type': 'NONE'},
            {'x': 230.5, 'y': 301, 'w': 147, 'h': 56, 'type': 'NONE'},
            {'x': 400.5, 'y': 292, 'w': 133, 'h': 74, 'type': 'NONE'},
        ]

    def check_feet_collision(self, px, py, is_falling_through_cloud=False):
        for b in self.ground_boxes:
            if b['type'] == 'LADDER':
                continue
            min_x = b['x'] - b['w'] / 2
            max_x = b['x'] + b['w'] / 2
            min_y = b['y'] - b['h'] / 2
            max_y = b['y'] + b['h'] / 2

            if b['type'] == 'NONE':
                if min_x <= px <= max_x and min_y - 2 <= py <= max_y:
                    return True, min_y

        if 127 <= px <= 157:
            ramp_y = 255 if px <= 133 else 255 + (px - 133) * 0.75
            if ramp_y - 4 <= py <= ramp_y + 14:
                return True, ramp_y

        if 304 <= px <= 334:
            ramp_y = 273 - (px - 304) * 0.75 if px <= 328 else 255
            if ramp_y - 4 <= py <= ramp_y + 14:
                return True, ramp_y

        return False, py

    def check_wall_collision(self, px, py, half_width=6, height=18):
        left = px - half_width
        right = px + half_width
        top = py - height
        bottom = py - 2

        for b in self.ground_boxes:
            if b['type'] != 'NONE':
                continue
            min_x = b['x'] - b['w'] / 2
            max_x = b['x'] + b['w'] / 2
            min_y = b['y'] - b['h'] / 2
            max_y = b['y'] + b['h'] / 2

            if right > min_x and left < max_x and bottom > min_y and top < max_y:
                push_left = min_x - right
                push_right = max_x - left
                push_x = push_left if abs(push_left) < abs(push_right) else push_right
                return True, push_x
        return False, 0

map_obj = MockStorageMap()

print("--- Simulating walking LEFT up stair02 from x=165 to x=115 ---")
# Start at x=165, y=273 on the ground
pos_x = 165.0
pos_y = 273.0
is_grounded = True
air_vel_y = 0.0

for tick in range(100):
    # Player update logic from Player.ts:
    run_speed = 1.7
    move_dir = -1 # Moving LEFT
    air_vel_x = move_dir * run_speed

    if is_grounded:
        # Check groundCheck:
        ground_check, ground_y = map_obj.check_feet_collision(pos_x, pos_y + 2)
        if not ground_check:
            is_grounded = False
            print(f"Tick {tick}: LOST GROUND at x={pos_x:.2f}, y={pos_y:.2f}!")
    else:
        air_vel_y += 0.6 # gravity
        if air_vel_y >= 0:
            next_y = pos_y + air_vel_y
            g_hit, g_y = map_obj.check_feet_collision(pos_x, next_y)
            if g_hit:
                is_grounded = True
                air_vel_y = 0
                pos_y = g_y
                print(f"Tick {tick}: LANDED at x={pos_x:.2f}, y={pos_y:.2f}")

    pos_x += air_vel_x
    wall_hit, push_x = map_obj.check_wall_collision(pos_x, pos_y)
    if wall_hit:
        pos_x += push_x
        print(f"Tick {tick}: WALL HIT at x={pos_x:.2f}, push={push_x:.2f}")

    if not is_grounded:
        pos_y += air_vel_y

    # If grounded on slope, what updates pos_y?!
    # LOOK AT PLAYER.TS! In Player.ts, if isGrounded is true:
    # NOTHING UPDATED pos_y WHEN WALKING ON A SLOPE! pos_y stayed at 273!
    print(f"Tick {tick}: pos=({pos_x:.2f}, {pos_y:.2f}), grounded={is_grounded}, airVelY={air_vel_y:.2f}")
    if pos_x < 120 or pos_y > 350:
        break
