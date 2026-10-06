# -*- coding: utf-8 -*-
"""Scan ABC constant-pool strings of main + sub SWFs: CJK strings, embedFonts, font names."""
import struct, sys
sys.path.insert(0, r"C:\Bleach VS Naruto")
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import _swflib as L


def scan(name, body):
    print("=" * 60)
    print(name, " body:", len(body))
    for tc, off, ln in L.iter_tags(body):
        if tc == 82:  # DoABC
            abc = body[off:off+ln]
            sc, strings, ranges, end = L.abc_strings(abc)
            print(f"  DoABC '{abc[4:abc.find(b'\\x00', 4)].decode('utf-8', 'replace')}' strings={sc}")
            cjk = [s for s in strings if any(0x2E80 <= b <= 0xFFFF for b in [])]
            n_cjk = 0
            for idx, s in enumerate(strings):
                try:
                    t = s.decode("utf-8")
                except UnicodeDecodeError:
                    continue
                if any(0x3000 <= ord(ch) <= 0x9FFF or 0xFF00 <= ord(ch) <= 0xFFEF for ch in t):
                    n_cjk += 1
                    if n_cjk <= 400:
                        print(f"   [{idx:5}] {t!r}")
            print(f"  total CJK strings: {n_cjk}")
            for p in ("embedFonts", "黑体", "微软雅黑", "defaultTextFormat", "SimHei"):
                hits = [i for i, s in enumerate(strings) if p.encode() in s]
                if hits:
                    print(f"  '{p}' in strings idx {hits[:10]} : {[strings[i][:60] for i in hits[:5]]}")
                raw = abc.count(p.encode())
                if raw:
                    print(f"  '{p}' raw hits in ABC: {raw}")


_out = open(r"C:\Bleach VS Naruto\_abc_scan_out.txt", "w", encoding="utf-8")
sys.stdout = _out

body = L.read_swf(r"C:\Bleach VS Naruto\Game\FighterTester.swf")[8:]
scan("MAIN FighterTester.swf", body)
for i in range(1, 9):
    b = L.read_swf(rf"C:\Bleach VS Naruto\_swf_imgs\binary_{i}.swf")[8:]
    scan(f"binary_{i}.swf", b)
sys.stdout.close()
