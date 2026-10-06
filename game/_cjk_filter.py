# -*- coding: utf-8 -*-
import re, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
lines = open(r"C:\Bleach VS Naruto\_abc_scan_out.txt", encoding="utf-8", errors="replace").read().splitlines()
out = [l for l in lines if re.match(r"\s*\[\s*\d+\]", l)]
print("count:", len(out))
w = open(r"C:\Bleach VS Naruto\_cjk_list.txt", "w", encoding="utf-8")
w.write("\n".join(out))
w.close()
for l in out:
    print(l)
