# -*- coding: utf-8 -*-
"""Analyze embedded UI sub-SWFs: tags, fonts (codepoints), static text, exports, images."""
import struct, sys, os
sys.path.insert(0, r"C:\Bleach VS Naruto")
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import _swflib as L

OUTDIR = r"C:\Bleach VS Naruto\_swf_imgs"

for i in range(1, 9):
    fn = f"{OUTDIR}\\binary_{i}.swf"
    body = L.read_swf(fn)[8:]  # strip 8-byte SWF header; iter_tags expects body only
    print("=" * 70)
    print(f"binary_{i}.swf  body={len(body)}")
    from collections import Counter
    c = Counter()
    for tc, off, ln in L.iter_tags(body):
        c[tc] += 1
    print("tags:", dict(sorted(c.items())))
    fonts, _ = L.font_code_tables(body)
    for fid, nm, cnt, codes in fonts:
        s = "".join(chr(x) for x in codes if 32 <= x < 0x2FFF)
        cjk = [x for x in codes if 0x4E00 <= x <= 0x9FFF]
        print(f"  FONT id={fid} glyphs={cnt} cjk={len(cjk)}")
        print(f"    latin: {s!r}")
    try:
        texts = L.static_texts(body)
        for cid, fid, s in texts:
            if s.strip():
                print(f"  TEXT id={cid} font={fid}: {s!r}")
    except Exception as e:
        print("  text parse error:", e)
    ex = L.exports(body)
    sc = L.symbol_classes(body)
    if ex:
        print("  exports:", ex[:12], "..." if len(ex) > 12 else "")
    if sc:
        print("  symbolclass:", sc[:12], "..." if len(sc) > 12 else "")
    imgs = L.extract_images(body, OUTDIR, f"sub{i}")
    if imgs:
        print("  images:", [os.path.basename(x) for x in imgs])
