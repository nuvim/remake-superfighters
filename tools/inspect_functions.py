import re

player_as = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code\Data\Players\Player.as"

with open(player_as, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

def print_function(start_line, max_lines=100):
    for i in range(start_line - 1, min(start_line - 1 + max_lines, len(lines))):
        print(f"L{i+1}: {lines[i]}", end='')
        if lines[i].strip() == '}' and i > start_line:
            # Check indentation to see if it's the closing brace of the function
            if lines[i].startswith('      }'):
                break

print("=== MovePlayer ===")
print_function(3883, 50)

print("\n=== UpdateGroundMovement ===")
print_function(4497, 60)

print("\n=== WalkCollision ===")
print_function(8082, 80)

print("\n=== CollisionFeetMidUp & CollisionFeetMid ===")
print_function(8206, 70)
