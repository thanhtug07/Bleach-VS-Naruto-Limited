# -*- coding: utf-8 -*-
"""Parse SWF tag structure: inventory + extract embedded images."""
import re, struct, sys, os, lzma, zlib

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
SRC = r"C:\Bleach VS Naruto\Game\FighterTester.swf"
OUTDIR = r"C:\Bleach VS Naruto\_swf_imgs"
os.makedirs(OUTDIR, exist_ok=True)

data = open(SRC, "rb").read()
tag = data[0:3].decode("ascii")
file_len = struct.unpack("<I", data[4:8])[0]

if tag == "ZWS":
    props = data[12:17]
    p0 = props[0]
    lc, lp, pb = p0 % 9, (p0 // 9) % 5, p0 // 45
    dict_size = int.from_bytes(props[1:5], "little")
    filters = [{"id": lzma.FILTER_LZMA1, "dict_size": dict_size, "lc": lc, "lp": lp, "pb": pb}]
    dec = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=filters)
    raw = dec.decompress(data[17:])
elif tag == "CWS":
    raw = zlib.decompress(data[8:])
else:
    raw = data

print("body size:", len(raw))

# skip RECT (frame size) at start of body
nbits = raw[0] >> 3
rect_bytes = (5 + 4 * nbits + 7) // 8
pos = rect_bytes + 4  # + frame rate (2) + frame count (2)
print("rect bytes:", rect_bytes, "| tags start at", pos)

TAGNAMES = {0:"End",1:"ShowFrame",9:"SetBackgroundColor",14:"DefineStartSound",20:"DefineBitsLossless",
            21:"DefineBitsJPEG2",22:"DefineShape2",24:"DefineShape4",26:"PlaceObject2",28:"RemoveObject2",
            32:"DefineShape3",34:"DefineButton2",35:"DefineBitsJPEG3",36:"DefineBitsLossless2",
            37:"DefineEditText",39:"DefineSprite",43:"FrameLabel",45:"SoundStreamHead2",
            46:"DefineMorphShape",48:"DefineBitsLossless-?",59:"DoInitAction",65:"ScriptLimits",
            69:"FileAttributes",70:"PlaceObject3",73:"DefineFontAlignZones",75:"DefineFont3",
            76:"DefineFontName",82:"DoABC",83:"DefineShape4b",84:"DefineShape5",86:"DefineSceneAndFrameLabelData",
            87:"DefineBinaryData",88:"DefineFontName2",91:"DefineFont4",93:"EnableTelemetry"}

tags = []
img_idx = 0
while pos < len(raw) - 1:
    tc_len = struct.unpack("<H", raw[pos:pos+2])[0]
    tc = tc_len >> 6
    tlen = tc_len & 0x3F
    pos += 2
    if tlen == 0x3F:
        tlen = struct.unpack("<I", raw[pos:pos+4])[0]
        pos += 4
    body = raw[pos:pos+tlen]
    name = TAGNAMES.get(tc, f"Tag{tc}")
    tags.append((tc, name, tlen))
    if tc in (20, 21, 35, 36, 90):
        img_idx += 1
        if tc == 20 or tc == 36:
            # DefineBitsLossless(2): charId(2) format(1) width(2) height(2) then data (zlib)
            cid = struct.unpack("<H", body[0:2])[0]
            fmt = body[2]
            w = struct.unpack("<H", body[3:5])[0]
            h = struct.unpack("<H", body[5:7])[0]
            open(f"{OUTDIR}\\lossless_{cid}.bin", "wb").write(body[7:])
            print(f"img#{img_idx} Tag{tc} id={cid} fmt={fmt} {w}x{h} datalen={tlen-7}")
        elif tc == 21:
            cid = struct.unpack("<H", body[0:2])[0]
            open(f"{OUTDIR}\\jpeg2_{cid}.jpg", "wb").write(body[2:])
            print(f"img#{img_idx} JPEG2 id={cid} datalen={tlen-2}")
        else:  # 35 JPEG3 / 90 JPEG4: charId(2) + alphaLen(4) + jpeg + alpha
            cid = struct.unpack("<H", body[0:2])[0]
            open(f"{OUTDIR}\\jpeg3_{cid}.jpg", "wb").write(body[6:])
            print(f"img#{img_idx} JPEG3 id={cid} datalen={tlen-6}")
    if tc == 87:  # DefineBinaryData: charId(2) reserved(4) data
        cid = struct.unpack("<H", body[0:2])[0]
        blob = body[6:]
        magic = blob[0:3].decode("ascii", "replace")
        open(f"{OUTDIR}\\binary_{cid}.swf", "wb").write(blob)
        print(f"bin#{cid} magic={magic} size={len(blob)}")
    pos += tlen

print()
from collections import Counter
c = Counter((t[0], t[1]) for t in tags)
for (tc, name), n in sorted(c.items()):
    print(f"Tag {tc:3} {name:28} x{n}")

# DoABC flags/name
pos2 = rect_bytes + 4
while pos2 < len(raw) - 1:
    tc_len = struct.unpack("<H", raw[pos2:pos2+2])[0]
    tc = tc_len >> 6
    tlen = tc_len & 0x3F
    hdr = 2
    if tlen == 0x3F:
        tlen = struct.unpack("<I", raw[pos2+2:pos2+6])[0]
        hdr = 6
    if tc == 82:
        body = raw[pos2+hdr:pos2+hdr+tlen]
        flags = struct.unpack("<I", body[0:4])[0]
        nm = body[4:].split(b"\x00")[0].decode("utf-8", "replace")
        print(f"DoABC: flags={flags} name={nm!r} size={tlen}")
    pos2 += hdr + tlen




