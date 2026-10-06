# -*- coding: utf-8 -*-
"""Dump static DefineText + EditText from sub-SWFs using fixed code tables."""
import struct, sys
sys.path.insert(0, r"C:\Bleach VS Naruto")
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
import _swflib as L


def edit_texts(body):
    """DefineEditText(37): return [(charId, initialText)]."""
    out = []
    for tc, off, ln in iter_edit(body):
        out.append(tc)
    return out


def iter_edit(body):
    for tc, off, ln in L.iter_tags(body):
        if tc != 37:
            continue
        b = body[off:off+ln]
        cid = struct.unpack("<H", b[0:2])[0]
        f = struct.unpack("<H", b[2:4])[0]
        hasText = (f >> 15) & 1
        hasTextColor = (f >> 13) & 1
        hasMaxLength = (f >> 12) & 1
        hasFont = (f >> 11) & 1
        hasFontClass = (f >> 10) & 1
        autosize = (f >> 9) & 1
        hasLayout = (f >> 8) & 1
        noSelect = (f >> 6) & 1
        border = (f >> 4) & 1
        html = (f >> 2) & 1
        useOutlines = f & 1
        p = 4
        if hasText:
            slen = struct.unpack("<H", b[p:p+2])[0]; p += 2
            txt = b[p:p+slen].decode("utf-8", "replace"); p += slen
            yield (cid, txt)
        # don't need the rest
        yield (cid, None)


for i in range(1, 9):
    fn = rf"C:\Bleach VS Naruto\_swf_imgs\binary_{i}.swf"
    body = L.read_swf(fn)[8:]
    print("=" * 60)
    print(f"binary_{i}.swf")
    fonts, _ = L.font_code_tables(body)
    for fid, nm, cnt, codes in fonts:
        s = "".join(chr(x) if 0x20 <= x <= 0x9FFF else "." for x in codes)
        print(f"  FONT id={fid} name={nm!r} glyphs={cnt}: {s}")
    for tc, off, ln in L.iter_tags(body):
        if tc in (11, 33):
            try:
                for cid, fid, s in L.static_texts(body):
                    if s.strip():
                        print(f"  STATICTEXT id={cid} font={fid}: {s!r}")
            except Exception as e:
                print("  statictext parse err:", e)
            break_outer = True
    # simpler: call once
    try:
        for cid, fid, s in L.static_texts(body):
            if s.strip():
                print(f"  STATICTEXT id={cid} font={fid}: {s!r}")
    except Exception as e:
        print("  statictext parse err:", e)
    for cid, txt in iter_edit(body):
        if txt:
            print(f"  EDITTEXT id={cid}: {txt!r}")
