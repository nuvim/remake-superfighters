with open(r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml", 'r', encoding='utf-8', errors='ignore') as f:
    recording = False
    cur_id = None
    lines_buf = []
    for line in f:
        if 'type="DefineSpriteTag"' in line:
            for sid in [47, 50, 75]:
                if f'spriteId="{sid}"' in line:
                    recording = True
                    cur_id = sid
                    lines_buf = [line]
                    break
        elif recording:
            lines_buf.append(line)
            if '</subTags>' in line:
                recording = False
                print(f"=== DefineSpriteTag {cur_id} ===")
                for l in lines_buf:
                    print(l.strip())
                print()
