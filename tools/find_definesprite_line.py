with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    for idx, line in enumerate(f):
        if 'DefineSprite' in line:
            print(f"L{idx+1}: {line.strip()[:100]}")
            break
