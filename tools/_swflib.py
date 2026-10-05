# -*- coding: utf-8 -*-
"""Minimal SWF toolkit: decompress, tag walker, fonts/text/images dump, ABC string table."""
import lzma, struct, zlib, sys, os

def read_swf(path):
    data = open(path, "rb").read()
    tag = data[0:3].decode("ascii", "replace")
    if tag == "ZWS":
        props = data[12:17]
        p0 = props[0]
        lc, lp, pb = p0 % 9, (p0 // 9) % 5, p0 // 45
        dict_size = int.from_bytes(props[1:5], "little")
        filters = [{"id": lzma.FILTER_LZMA1, "dict_size": dict_size, "lc": lc, "lp": lp, "pb": pb}]
        dec = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=filters)
        body = dec.decompress(data[17:])
        return data[:8] + body  # normalized: header(8) + uncompressed body
    if tag == "CWS":
        return data[:8] + zlib.decompress(data[8:])
    return data

def rect_skip(buf, pos):
    nbits = buf[pos] >> 3
    return pos + (5 + 4 * nbits + 7) // 8

def iter_tags(body):
    pos = rect_skip(body, 0) + 4
    end = len(body)
    while pos < end - 1:
        tc_len = struct.unpack("<H", body[pos:pos+2])[0]
        tc = tc_len >> 6
        tlen = tc_len & 0x3F
        hdr = 2
        if tlen == 0x3F:
            tlen = struct.unpack("<I", body[pos+2:pos+6])[0]
            hdr = 6
        if tc == 0:
            return
        yield tc, pos + hdr, tlen
        pos += hdr + tlen

def read_u30(buf, pos):
    val = 0
    shift = 0
    for _ in range(5):
        b = buf[pos]
        pos += 1
        val |= (b & 0x7F) << shift
        shift += 7
        if not (b & 0x80):
            break
    return val, pos

def read_varint32(buf, pos):
    return read_u30(buf, pos)

def body_find_zero(buf, pos):
    while buf[pos] != 0:
        pos += 1
    return pos

class BitReader:
    def __init__(self, buf, bitpos=0):
        self.buf = buf
        self.p = bitpos
    def bits(self, n):
        v = 0
        for _ in range(n):
            byte = self.buf[self.p >> 3]
            bit = (byte >> (7 - (self.p & 7))) & 1
            v = (v << 1) | bit
            self.p += 1
        return v


def font_code_tables(body):
    """Return ([(fontId, fontName, glyphCount, codepoints)], names). Handles DefineFont(10)/DefineFont2(62)/DefineFont3(75)."""
    names = {}
    fonts = []
    for tc, off, ln in iter_tags(body):
        if tc not in (10, 62, 75):
            continue
        try:
            fid = struct.unpack("<H", body[off:off+2])[0]
            if tc == 10:
                glyphCount = struct.unpack("<H", body[off+2:off+4])[0]
                p = off + 4
                offsets = []
                for i in range(glyphCount + 1):
                    offsets.append(struct.unpack("<H", body[p:p+2])[0]); p += 2
                codeTableOffset = offsets[-1]
                ct_pos = p + codeTableOffset
                codes = [body[ct_pos + i] for i in range(glyphCount)]
                fonts.append((fid, f"v1font{fid}", glyphCount, codes))
                continue
            flags = body[off+2]
            hasLayout = (flags >> 7) & 1
            wideOffsets = (flags >> 3) & 1
            wideCodes = (flags >> 2) & 1
            langCode = body[off+3]          # LanguageCode is UI8 in SWF tag defs for font2/3
            nameLen = body[off+4]
            p = off + 5
            fontName = body[p:p+nameLen].split(b"\x00")[0].decode("utf-8", "replace")
            p += nameLen
            glyphCount = struct.unpack("<H", body[p:p+2])[0]
            p += 2
            offsets = []
            if wideOffsets:
                for i in range(glyphCount):
                    offsets.append(struct.unpack("<I", body[p:p+4])[0]); p += 4
                codeTableOffset = struct.unpack("<I", body[p:p+4])[0]; p += 4
            else:
                for i in range(glyphCount):
                    offsets.append(struct.unpack("<H", body[p:p+2])[0]); p += 2
                codeTableOffset = struct.unpack("<H", body[p:p+2])[0]; p += 2
            ct_pos = (off + 2) + codeTableOffset  # empirically correct: base is just after FontId
            codes = []
            for i in range(glyphCount):
                if tc == 75:
                    if ct_pos + 2 > len(body):
                        raise IndexError("code table OOB")
                    codes.append(struct.unpack("<H", body[ct_pos:ct_pos+2])[0]); ct_pos += 2
                else:
                    if ct_pos + 1 > len(body):
                        raise IndexError("code table OOB")
                    codes.append(body[ct_pos]); ct_pos += 1
        except (IndexError, struct.error) as e:
            print(f"  ! font parse failed tc={tc} off={off} len={ln} err={e}")
            print(f"    hex: {body[off:off+56].hex(' ')}")
            continue
        fonts.append((fid, fontName, glyphCount, codes))
    return fonts, names


def static_texts(body):
    """Return [(charId, fontId, text)] for DefineText(11)/DefineText2(33)."""
    fmap = {}
    for fid, nm, cnt, codes in font_code_tables(body)[0]:
        fmap[fid] = codes
    out = []
    for tc, off, ln in iter_tags(body):
        if tc not in (11, 33):
            continue
        cid = struct.unpack("<H", body[off:off+2])[0]
        p = rect_skip(body, off + 2)
        br = BitReader(body, p * 8)
        hasScale = br.bits(1)
        if hasScale:
            nbits = br.bits(5); br.bits(nbits); br.bits(nbits)
        hasRotate = br.bits(1)
        if hasRotate:
            nbits = br.bits(5); br.bits(nbits); br.bits(nbits)
        nbits = br.bits(5)
        br.bits(nbits); br.bits(nbits)
        p = (br.p + 7) // 8
        p += 3 if tc == 11 else 4
        glyphBits = body[p] >> 4
        advBits = body[p] & 0x0F
        p += 1
        cur_codes = None
        cur_str = ""
        end = off + ln
        while p < end:
            b = body[p]
            if b == 0:
                p += 1
                break
            if (b >> 7) & 1:
                glyphCount = b & 0x7F
                p += 1
                fidx = struct.unpack("<H", body[p:p+2])[0]
                p += 2
                cur_codes = fmap.get(fidx)
                br = BitReader(body, p * 8)
                for i in range(glyphCount):
                    gi = br.bits(glyphBits)
                    br.bits(advBits)
                    if cur_codes and gi < len(cur_codes):
                        cur_str += chr(cur_codes[gi])
                p = (br.p + 7) // 8
            else:
                styleFlags = b
                p += 1
                if (styleFlags >> 2) & 1:
                    fidx = struct.unpack("<H", body[p:p+2])[0]
                    cur_codes = fmap.get(fidx)
                    p += 2
                    br = BitReader(body, p * 8)
                    br.bits(16)
                    p = (br.p + 7) // 8
                if (styleFlags >> 3) & 1:
                    p += 4 if tc == 33 else 3
                if (styleFlags >> 1) & 1:
                    p += 2
                if styleFlags & 1:
                    p += 2
        out.append((cid, cur_font_of(cur_codes, fmap), cur_str))
    return out

def cur_font_of(codes, fmap):
    for fid, c in fmap.items():
        if c is codes:
            return fid
    return None

def exports(body):
    names = []
    for tc, off, ln in iter_tags(body):
        if tc == 56:  # ExportAssets
            cnt = struct.unpack("<H", body[off:off+2])[0]
            p = off + 2
            for _ in range(cnt):
                p += 2
                nm = body[p:].split(b"\x00")[0].decode("utf-8", "replace"); p += len(nm) + 1
                names.append(nm)
        elif tc == 76 and False:
            pass
    return names

def symbol_classes(body):
    names = []
    for tc, off, ln in iter_tags(body):
        if tc == 76:  # SymbolClass
            cnt = struct.unpack("<H", body[off:off+2])[0]
            p = off + 2
            for _ in range(cnt):
                p += 2
                nm = body[p:].split(b"\x00")[0].decode("utf-8", "replace"); p += len(nm) + 1
                names.append(nm)
    return names

def extract_images(body, outdir, prefix):
    made = []
    for tc, off, ln in iter_tags(body):
        b = body[off:off+ln]
        if tc in (21, 35, 90):
            cid = struct.unpack("<H", b[0:2])[0]
            img = b[2:] if tc == 21 else b[6:]
            fn = f"{outdir}\\{prefix}_img{cid}.jpg"
            open(fn, "wb").write(img)
            made.append(fn)
        elif tc in (20, 36):
            cid = struct.unpack("<H", b[0:2])[0]
            fn = f"{outdir}\\{prefix}_lossless{cid}.bin"
            open(fn, "wb").write(b[7:])
            made.append(fn)
    return made

def abc_strings(abc_body):
    """abc_body = DoABC tag content (flags u32 + name\0 + abc). Return (sc, strings, ranges, end_of_strings).

    NOTE: pool counts include the implicit entry 0 -> file contains count-1 entries.
    """
    p = body_find_zero(abc_body, 4) + 1
    p += 4  # minor, major version
    ic, p = read_u30(abc_body, p)
    for _ in range(ic - 1):
        _, p = read_varint32(abc_body, p)
    uc, p = read_u30(abc_body, p)
    for _ in range(uc - 1):
        _, p = read_varint32(abc_body, p)
    dc, p = read_u30(abc_body, p)
    p += 8 * (dc - 1)
    sc, p = read_u30(abc_body, p)
    strings = []
    ranges = []
    for _ in range(sc - 1):
        slen, p = read_u30(abc_body, p)
        strings.append(abc_body[p:p+slen])
        ranges.append((p, p + slen))
        p += slen
    return sc, strings, ranges, p

