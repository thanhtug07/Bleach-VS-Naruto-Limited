# -*- coding: utf-8 -*-
"""Convert DefineBitsLossless(2) blobs to PNG for viewing."""
import zlib, struct, sys, os
sys.path.insert(0, r"C:\Bleach VS Naruto")
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

OUTDIR = r"C:\Bleach VS Naruto\_swf_imgs"


def write_png(fn, w, h, rgba_rows):
    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        return c + struct.pack(">I", zlib.crc32(typ + data) & 0xFFFFFFFF)
    raw = b"".join(b"\x00" + row for row in rgba_rows)
    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 6))
           + chunk(b"IEND", b""))
    open(fn, "wb").write(png)


def convert(binfile, outpng):
    data = open(binfile, "rb").read()
    raw = zlib.decompress(data)
    # caller must pass fmt,w,h — encoded in filename? read from companion? We'll take params
    raise SystemExit("use convert2")


def convert2(binfile, outpng, fmt, w, h, colormap=None):
    data = open(binfile, "rb").read()
    raw = zlib.decompress(data)
    rows = []
    if fmt == 3:  # colormapped 8-bit
        bpp = (w + 3) // 4 * 4  # padded to 32-bit boundary per row
        for y in range(h):
            row = bytearray()
            base = y * bpp
            for x in range(w):
                idx = raw[base + x]
                r, g, b, a = colormap[idx]
                row += bytes((r, g, b, a))
            rows.append(bytes(row))
    elif fmt == 5:  # 32-bit straight ARGB (big-endian in file, but Flash stores BGRA little-endian after fixups)
        stride = w * 4
        for y in range(h):
            row = bytearray()
            base = y * stride
            for x in range(w):
                b0, g, b, a = raw[base + x*4:base + x*4 + 4]
                row += bytes((b, g, b0, a))
            rows.append(bytes(row))
    else:
        raise ValueError(f"fmt {fmt} unsupported")
    write_png(outpng, w, h, rows)


def find_lossless(swf, cid):
    body = L.read_swf(swf)[8:]
    import _swflib as L2
    for tc, off, ln in L.iter_tags(body):
        if tc in (20, 36):
            b = body[off:off+ln]
            i = struct.unpack("<H", b[0:2])[0]
            if i == cid:
                fmt = b[2]
                w = struct.unpack("<H", b[3:5])[0]
                h = struct.unpack("<H", b[5:7])[0]
                return fmt, w, h, b[7:]
    return None


import _swflib as L
if __name__ == "__main__":
    jobs = [
        (r"C:\Bleach VS Naruto\_swf_imgs\binary_2.swf", [2, 4, 6, 9, 15, 23, 25, 36, 48, 53, 60], "t2"),
        (r"C:\Bleach VS Naruto\_swf_imgs\binary_7.swf", [6, 9, 11, 18, 21], "t7"),
        (r"C:\Bleach VS Naruto\_swf_imgs\binary_1.swf", [1, 3, 5, 7, 48, 53, 55, 67, 70, 73, 96, 99], "t1"),
    ]
    for swf, ids, pref in jobs:
        for cid in ids:
            r = find_lossless(swf, cid)
            if not r:
                print("missing", swf, cid)
                continue
            fmt, w, h, data = r
            print(f"{pref} loss{cid}: fmt={fmt} {w}x{h} first={data[:8].hex(' ')}")
            out = rf"{OUTDIR}\{pref}_loss{cid}.png"
            try:
                if data[1:2] == b"\x78" and data[0:1] != b"\x78":
                    data = data[1:]  # authoring-tool quirk: one stray prefix byte before zlib stream
                raw = zlib.decompress(data)
                if fmt == 3:
                    bpp = (w + 3) // 4 * 4
                    csize = len(raw) - h * bpp
                    if csize < 0:
                        raise ValueError(f"csize<0 raw={len(raw)} need={h*bpp}")
                    ncolors = csize // 4
                    cm = [tuple(raw[len(raw) - ncolors*4 + i*4: len(raw) - ncolors*4 + i*4 + 4]) for i in range(ncolors)]
                    rows = []
                    for y in range(h):
                        row = bytearray()
                        base = y * bpp
                        for x in range(w):
                            r, g, b, a = cm[raw[base + x]]
                            row += bytes((r, g, b, a))
                        rows.append(bytes(row))
                    write_png(out, w, h, rows)
                elif fmt == 5:
                    rows = []
                    stride = w * 4
                    for y in range(h):
                        row = bytearray()
                        base = y * stride
                        for x in range(w):
                            r, g, b, a = raw[base + x*4:base + x*4 + 4]
                            row += bytes((r, g, b, a))
                        rows.append(bytes(row))
                    write_png(out, w, h, rows)
                else:
                    print(f"   fmt={fmt} unsupported")
                    continue
                print(f"   -> {os.path.basename(out)} OK")
            except Exception as e:
                print(f"   ERR {e}")
