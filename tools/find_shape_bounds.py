with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        for cid in [45, 49, 74]:
            if f'shapeId="{cid}"' in line or f'characterId="{cid}"' in line:
                print(line.strip())
