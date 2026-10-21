def ts_point_in_polygon(x, y, verts):
    inside = False
    n = len(verts)
    p1x = verts[0][0]
    p1y = verts[0][1]
    for i in range(n + 1):
        p2x = verts[i % n][0]
        p2y = verts[i % n][1]
        if y > min(p1y, p2y) and y <= max(p1y, p2y) and x <= max(p1x, p2x):
            if p1y != p2y:
                xinters = ((y - p1y) * (p2x - p1x)) / (p2y - p1y) + p1x
                if p1x == p2x or x <= xinters:
                    inside = not inside
        p1x = p2x
        p1y = p2y
    return inside

def standard_point_in_poly(x, y, verts):
    inside = False
    j = len(verts) - 1
    for i in range(len(verts)):
        xi, yi = verts[i]
        xj, yj = verts[j]
        if ((yi > y) != (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi):
            inside = not inside
        j = i
    return inside

verts = [
    [126.5, 254.5],
    [133.5, 254.5],
    [157.5, 272.5],
    [157.5, 335.5],
    [126.5, 335.5]
]

x = 136.5
for y in [255.0, 257.0, 258.0, 259.0, 260.0]:
    print(f"y={y}: ts={ts_point_in_polygon(x, y, verts)}, standard={standard_point_in_poly(x, y, verts)}")
