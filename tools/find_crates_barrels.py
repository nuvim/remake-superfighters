import os
import re

code_dir = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code"

matches = []
for root, dirs, files in os.walk(code_dir):
    for f in files:
        if f.endswith('.as'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as file:
                content = file.read()
                if 'CreateCrate' in content or 'CreateBarrel' in content or 'CRATE' in content or 'BARREL' in content:
                    for line_num, line in enumerate(content.splitlines()):
                        if any(k in line for k in ['function CreateCrate', 'function CreateBarrel', 'b2BodyDef', 'density =', 'friction =', 'restitution =']):
                            matches.append((f, line_num + 1, line.strip()))

for m in matches[:50]:
    print(f"{m[0]}:L{m[1]}: {m[2]}")
