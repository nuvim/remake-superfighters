with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    for i in range(100):
        line = f.readline()
        if 'DefineSprite' in line or 'spriteId' in line:
            print(line.strip())
            break
