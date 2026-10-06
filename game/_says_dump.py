# -*- coding: utf-8 -*-
"""Dump unique say texts from fighter.xml + assistant.xml."""
import sys, xml.etree.ElementTree as ET
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

CFG = r"C:\Bleach VS Naruto\Game\assets\config"
seen = []
seen_set = set()
for f in ("fighter.xml", "assistant.xml"):
    root = ET.parse(rf"{CFG}\{f}").getroot()
    for el in root.iter("fighter"):
        says = el.find("says")
        if says is None:
            continue
        for s in says.iter("say_item"):
            t = (s.text or "").strip()
            if t and t not in seen_set:
                seen_set.add(t)
                seen.append(t)
print("unique says:", len(seen))
w = open(r"C:\Bleach VS Naruto\_says_list.txt", "w", encoding="utf-8")
for i, t in enumerate(seen):
    w.write(f"#{i:03}\t{t}\n")
w.close()
print("written to _says_list.txt")

