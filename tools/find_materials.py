import os

code_dir = r"H:\luizm\Documents\remake superfighters\decompiled\scripts\scripts\Code"

for root, dirs, files in os.walk(code_dir):
    for f in files:
        if 'Material' in f:
            path = os.path.join(root, f)
            print(f"=== {f} ===")
            with open(path, 'r', encoding='utf-8', errors='ignore') as file:
                print(file.read()[:1500])
