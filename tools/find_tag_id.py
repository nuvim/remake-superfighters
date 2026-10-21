with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    lines = [f.readline() for _ in range(10000)]

for i, l in enumerate(lines):
    if 'crate_01' in l or 'barrel_01' in l or 'barrel_02' in l:
        print(f"L{i+1}: {l.strip()}")
        # print previous 20 lines to find the tagId list
        for j in range(max(0, i - 10), min(len(lines), i + 10)):
            print(f"  {j+1}: {lines[j].strip()[:60]}")
        break
