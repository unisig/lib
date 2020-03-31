MAGIC = b"\xDC\xDC\x0D\x0A\x1A\x0A\x00"


def read(stream):
    head = stream.read(len(MAGIC) + 1)
    if len(head) != len(MAGIC) + 1 or head[: len(MAGIC)] != MAGIC:
        return False
    lenbyte = head[len(MAGIC)]
    is_uuid = lenbyte == 0
    length = 16 if is_uuid else lenbyte
    sig = stream.read(length)
    if len(sig) != length:
        return False
    return sig if is_uuid else sig.decode("utf-8", errors="strict")


def write(stream, name):
    if isinstance(name, bytes):
        assert len(name) == 16
        sig = name
        is_uuid = True
    else:
        assert isinstance(name, str)
        sig = name.encode("utf-8", errors="strict")
        is_uuid = False
    stream.write(MAGIC)
    stream.write(bytes([0 if is_uuid else len(sig)]))
    stream.write(sig)
