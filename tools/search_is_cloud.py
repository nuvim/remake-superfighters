import os

code_dir = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code"

for root, dirs, files in os.walk(code_dir):
    for f in files:
        if f.endswith('.as'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8', errors='ignore') as file:
                lines = file.readlines()
                for i, l in enumerate(lines):
                    if 'isCloud' in l:
                        print(f"{f}:L{i+1}: {l.strip()}")
