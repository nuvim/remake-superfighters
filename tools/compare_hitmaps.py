import json
import math

with open("superfighters-web/src/data/generated/storage.json", "r", encoding="utf-8") as f:
    storage = json.load(f)

# Load golden hitmaps
def load_golden(path):
    data = {}
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line: continue
            parts = line.split(":")
            data[int(parts[0])] = parts[1]
    return data

golden_world = load_golden("superfighters-web/tests/golden/hitmap_world.txt")
golden_cloud = load_golden("superfighters-web/tests/golden/hitmap_cloud.txt")
golden_ladder = load_golden("superfighters-web/tests/golden/hitmap_ladder.txt")

def point_in_poly(px, py, verts):
    inside = False
    n = len(verts)
    p1x, p1y = verts[0]
    for i in range(n + 1):
        p2x, p2y = verts[i % n]
        if min(p1y, p2y) < py <= max(p1y, p2y) and px <= max(p1x, p2x):
            if p1y != p2y:
                xinters = (py - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
                if p1x == p2x or px <= xinters:
                    inside = not inside
        p1x, p1y = p2x, p2y
    return inside

# 1. Test Ladder
ladder_boxes = [b for b in storage["groundBoxes"] if "LADDER" in b["tags"]]
ladder_total, ladder_diff = 0, 0
for y_idx in range(-60, 700):
    row = golden_ladder.get(y_idx, "")
    py = y_idx * 0.5
    for x_idx in range(1050):
        px = x_idx * 0.5
        gold = (row[x_idx] == "1") if x_idx < len(row) else False
        hit = False
        for b in ladder_boxes:
            minX = (b["x"] - b["widthExpanded"] / 2.0) * 30.0
            maxX = (b["x"] + b["widthExpanded"] / 2.0) * 30.0
            minY = (b["y"] - b["heightExpanded"] / 2.0) * 30.0
            maxY = (b["y"] + b["heightExpanded"] / 2.0) * 30.0
            if minX <= px <= maxX and minY <= py <= maxY:
                hit = True
                break
        ladder_total += 1
        if gold != hit: ladder_diff += 1

print(f"LADDER HITMAP: {ladder_total - ladder_diff} / {ladder_total} ({(ladder_total - ladder_diff)/ladder_total*100:.4f}%) - {ladder_diff} diffs")

# 2. Test Cloud
cloud_boxes = [b for b in storage["groundBoxes"] if "CLOUD" in b["tags"]]
cloud_total, cloud_diff = 0, 0
for y_idx in range(-60, 700):
    row = golden_cloud.get(y_idx, "")
    py = y_idx * 0.5
    for x_idx in range(1050):
        px = x_idx * 0.5
        gold = (row[x_idx] == "1") if x_idx < len(row) else False
        hit = False
        for b in cloud_boxes:
            angle = b["angle"]
            if abs(angle) > 0.001:
                dx = px - b["x"] * 30.0
                dy = py - b["y"] * 30.0
                cos_a = math.cos(-angle)
                sin_a = math.sin(-angle)
                lx = dx * cos_a - dy * sin_a
                ly = dx * sin_a + dy * cos_a
                hw = (b["widthExpanded"] * 30.0) / 2.0
                hh = (b["heightExpanded"] * 30.0) / 2.0
                if abs(lx) <= hw and abs(ly) <= hh:
                    hit = True
                    break
            else:
                minX = (b["x"] - b["widthExpanded"] / 2.0) * 30.0
                maxX = (b["x"] + b["widthExpanded"] / 2.0) * 30.0
                minY = (b["y"] - b["heightExpanded"] / 2.0) * 30.0
                maxY = (b["y"] + b["heightExpanded"] / 2.0) * 30.0
                if minX <= px <= maxX and minY <= py <= maxY:
                    hit = True
                    break
        cloud_total += 1
        if gold != hit: cloud_diff += 1

print(f"CLOUD HITMAP:  {cloud_total - cloud_diff} / {cloud_total} ({(cloud_total - cloud_diff)/cloud_total*100:.4f}%) - {cloud_diff} diffs")

# 3. Test World (Ground boxes + Polygons + Objects)
world_boxes = [b for b in storage["groundBoxes"] if "CLOUD" not in b["tags"] and "LADDER" not in b["tags"]]
world_polys = []
for p in storage["groundPolygons"]:
    poly_pts = []
    for vx, vy in p["expandedVertices"]:
        poly_pts.append((p["x"] * 30.0 + vx * 30.0, p["y"] * 30.0 + vy * 30.0))
    world_polys.append(poly_pts)

world_objects = storage["objects"]

world_total, world_diff = 0, 0
for y_idx in range(-60, 700):
    row = golden_world.get(y_idx, "")
    py = y_idx * 0.5
    for x_idx in range(1050):
        px = x_idx * 0.5
        gold = (row[x_idx] == "1") if x_idx < len(row) else False
        hit = False
        
        # Static boxes
        for b in world_boxes:
            minX = (b["x"] - b["widthExpanded"] / 2.0) * 30.0
            maxX = (b["x"] + b["widthExpanded"] / 2.0) * 30.0
            minY = (b["y"] - b["heightExpanded"] / 2.0) * 30.0
            maxY = (b["y"] + b["heightExpanded"] / 2.0) * 30.0
            if minX <= px <= maxX and minY <= py <= maxY:
                hit = True
                break
        
        # Static polygons
        if not hit:
            for poly in world_polys:
                if point_in_poly(px, py, poly):
                    hit = True
                    break
        
        # Dynamic objects
        if not hit:
            for obj in world_objects:
                ox = obj["x"] * 30.0
                oy = obj["y"] * 30.0
                angle = obj["angle"]
                pw = obj["pixelWidth"] + 0.5
                ph = obj["pixelHeight"] + 0.5
                dx = px - ox
                dy = py - oy
                if abs(angle) < 0.001:
                    if abs(dx) <= pw / 2.0 and abs(dy) <= ph / 2.0:
                        hit = True
                        break
                else:
                    cos_a = math.cos(-angle)
                    sin_a = math.sin(-angle)
                    lx = dx * cos_a - dy * sin_a
                    ly = dx * sin_a + dy * cos_a
                    if abs(lx) <= pw / 2.0 and abs(ly) <= ph / 2.0:
                        hit = True
                        break
        
        world_total += 1
        if gold != hit: world_diff += 1

print(f"WORLD HITMAP:  {world_total - world_diff} / {world_total} ({(world_total - world_diff)/world_total*100:.4f}%) - {world_diff} diffs")
