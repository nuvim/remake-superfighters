with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    for idx, line in enumerate(f):
        if idx >= 9675 and idx <= 9720:
            print(f"L{idx+1}: {line.strip()}")
