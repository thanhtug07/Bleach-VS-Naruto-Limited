    try:
        if data[1:2] == b"\x78" and data[0:1] != b"\x78":
            data = data[1:]  # authoring-tool quirk: one stray prefix byte before zlib stream
        raw = zlib.decompress(data)
        print("   -> decompressed OK")
    except Exception as e:
        print(f"   ERR {e}")
