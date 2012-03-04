def byte(b)
	return [b].pack('c')
end

def unsigned_byte(b)
	return [b].pack('C')
end

def short(s)
	return [s].pack('s>')
end

def int(i)
	return [i].pack('l>')
end

def long(l)
	return [l].pack('q>')
end

def float(f)
	return [f].pack('g')
end

def double(d)
	return [d].pack('G')
end

def string(s)
	return short(s.length) + s.encode('UCS-2BE').force_encoding('ASCII-8BIT')
end

def read_byte
	return @socket.read(1).unpack('c')[0]
end

def read_unsigned_byte
	return @socket.read(1).unpack('C')[0]
end

def read_short
	return @socket.read(2).unpack('s>')[0]
end

def read_int
	return @socket.read(4).unpack('l>')[0]
end

def read_long
	return @socket.read(8).unpack('q>')[0]
end

def read_float
	return @socket.read(4).unpack('g')[0]
end

def read_double
	return @socket.read(8).unpack('G')[0]
end

def read_string
	return @socket.read(read_short * 2).force_encoding('UCS-2BE')
end

ENCHANTABLE = [0x103, 0x105, 0x15A, 0x167,
               0x10C, 0x10D, 0x10E, 0x10F, 0x122,
               0x110, 0x111, 0x112, 0x113, 0x123,
               0x10B, 0x100, 0x101, 0x102, 0x124,
               0x114, 0x115, 0x116, 0x117, 0x125,
               0x11B, 0x11C, 0x11D, 0x11E, 0x126,
               0x12A, 0x12B, 0x12C, 0x12D,
               0x12E, 0x12F, 0x130, 0x131,
               0x132, 0x133, 0x134, 0x135,
               0x136, 0x137, 0x138, 0x139,
               0x13A, 0x13B, 0x13C, 0x13D]

def read_slot
	h = {}
  h[:id] = read_short
  if h[:id] != -1
		h[:count] = read_byte
		h[:damage] = read_short
		if ENCHANTABLE.include?(h[:id])
			enchant_data_len = read_short
			if enchant_data_len > 0
				h[:enchant_data] = @socket.read(enchant_data_len)
			end
		end
	end
	return h
end

def read_metadata
  buf = {}
	while (b = @socket.read(1).ord) != 0x7F
		buf[b & 0x1F] = case b >> 5
			when 0 then read_byte
			when 1 then read_short
			when 2 then read_int
			when 3 then read_float
			when 4 then read_string
			when 5 then read_slot
			when 6 then [read_int, read_int, read_int]
			end
  end
	return buf
end
