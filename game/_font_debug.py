# -*- coding: utf-8 -*-
"""Debug font code tables: try interpretations, pick plausible codepoints."""
import struct, sys
sys.path.insert(0, r"C:\Bleach VS Naruto")
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import _swflib as L

def score(codes):
    if not codes:
        return -1
    ok = sum(1 for c in codes if 0x20 <= c <= 0x9FFF)
    asc = sum(1 for a, b in zip(codes, codes[1:]) if b >= a)
    return ok / len(codes) + (asc / max(1, len(codes) - 1)) * 0.5

def try_font(body, off, ln):
    flags = body[off+2]
    wideOffsets = (flags >> 3) & 1
    wideCodes = (flags >> 2) & 1
    nameLen = body[off+4]
    p = off + 5 + nameLen
    glyphCount = struct.unpack("<H", body[p:p+2])[0]
    p += 2
    offsets = []
    step = 4 if wideOffsets else 2
    fmt = "<I" if wideOffsets else "<H"
    for i in range(glyphCount):
        offsets.append(struct.unpack(fmt, body[p:p+step])[0]); p += step
    ctoff = struct.unpack(fmt, body[p:p+step])[0]
    p += step
    best = None
    for base_name, base in [("glyphStart(p)", p), ("tagStart(off)", off), ("fontId(after)", off+2)]:
        for sign in (1, -1):
            ct = base + sign * ctoff
            for wc in (2, 1):
                if ct < 0 or ct + glyphCount * wc > len(body):
                    continue
                codes = []
                for i in range(glyphCount):
                    codes.append(struct.unpack("<H" if wc == 2 else "<B", body[ct+i*wc:ct+i*wc+wc])[0])
                s = score(codes)
                if best is None or s > best[0]:
                    best = (s, base_name, sign, wc, codes)
    return glyphCount, ctoff, best

for i in range(1, 9):
    fn = rf"C:\Bleach VS Naruto\_swf_imgs\binary_{i}.swf"
    body = L.read_swf(fn)[8:]
    for tc, off, ln in L.iter_tags(body):
        if tc in (62, 75):
            g, ctoff, best = try_font(body, off, ln)
            if best:
                s, bn, sign, wc, codes = best
                txt = "".join(chr(c) if 32 <= c <= 0x9FFF else "." for c in codes)
                print(f"binary_{i} font off={off} glyphs={g} ctoff={ctoff} => best score={s:.2f} base={bn} sign={sign} wc={wc}")
                print(f"   codes: {txt}")
            else:
                print(f"binary_{i} font off={off} glyphs={g} ctoff={cttoff} => NO plausible decode")
