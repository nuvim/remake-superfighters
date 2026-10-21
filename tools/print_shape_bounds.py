with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    for idx, line in enumerate(f):
        if 'shapeId="49"' in line or 'shapeId="45"' in line or 'shapeId="74"' in line:
            print(f"L{idx+1}: {line.strip()}")
            for j in range(10):
                print("  ", f.readline().strip())
