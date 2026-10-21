from PIL import Image
import os

paths = [
    r"H:\luizm\Documents\remake superfighters\decompiled\assets\sprites\DefineSprite_50_crate_01\1.png",
    r"H:\luizm\Documents\remake superfighters\decompiled\assets\sprites\DefineSprite_47_barrel_01\1.png",
    r"H:\luizm\Documents\remake superfighters\decompiled\assets\sprites\DefineSprite_75_barrel_02\1.png"
]

for p in paths:
    if os.path.exists(p):
        img = Image.open(p)
        print(f"{os.path.basename(os.path.dirname(p))}: {img.size}")
    else:
        print(f"Not found: {p}")
