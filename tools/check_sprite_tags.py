import xml.etree.ElementTree as ET
import re

swf_xml = r"H:\luizm\Documents\remake superfighters\tools\extract\swf.xml"

with open(swf_xml, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

for sprite_id in [50, 47, 75]:
    pattern = f'<DefineSpriteTag spriteId="{sprite_id}".*?</DefineSpriteTag>'
    match = re.search(pattern, content, re.DOTALL)
    if match:
        print(f"=== DefineSpriteTag {sprite_id} ===")
        print(match.group(0)[:800])
        print("...")
