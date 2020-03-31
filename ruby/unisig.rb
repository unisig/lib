MAGIC = [0xDC, 0xDC, 0x0D, 0x0A, 0x1A, 0x0A, 0x00].pack("C*")

def read(io)
  raise unless io.binmode?
  head = io.read(MAGIC.length + 1)
  if head.length != MAGIC.length + 1
    return false
  end
  if head.slice(0, MAGIC.length) != MAGIC
    return false
  end
  lenbyte = head[MAGIC.length].ord
  is_uuid = (lenbyte == 0)
  len = (if is_uuid then 16 else lenbyte end)
  sig = io.read(len)
  return false if sig.length != len
  if is_uuid then sig.unpack("C*") else sig.force_encoding("UTF-8") end
end

def write(io, name)
  raise unless name.length <= 255
  raise unless io.binmode?
  if name.is_a?(Array)
    raise unless name.length == 16
    sig = name
    is_uuid = true
  else
    raise unless name.is_a?(String)
    sig = name.unpack("utf-8", "U*")
    is_uuid = false
  end
  io.write(MAGIC)
  io.write(bytes([if is_uuid then 0 else sig.length end]))
  io.write(sig)
end
