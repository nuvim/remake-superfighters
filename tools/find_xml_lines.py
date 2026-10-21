with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    for idx, line in enumerate(f):
        if 'crate_01' in line or 'barrel_01' in line or 'barrel_02' in line:
            print(f"L{idx+1}: {line.strip()[:100]}")
            if idx > 50000:
                break
