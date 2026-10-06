# -*- coding: utf-8 -*-
"""Dump all id/name pairs from game config XMLs."""
import sys, xml.etree.ElementTree as ET
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

CFG = r"C:\Bleach VS Naruto\Game\assets\config"
for f, tagname in [("fighter.xml", "fighter"), ("assistant.xml", "fighter"), ("map.xml", "map")]:
    print("=" * 20, f)
    root = ET.parse(rf"{CFG}\{f}").getroot()
    for el in root.iter(tagname):
        if el.get("name"):
            print(f"{el.get('id')}\t{el.get('name')}")
