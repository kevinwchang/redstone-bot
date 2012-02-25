#!/usr/bin/ruby

require 'socket'
require 'io/wait'
require 'iconv'
require 'rubygems'
require 'fastthread'

def short(s)
  return [s].pack('n')
end

def int(i)
  return [i].pack('N')
end

def long(l)
  return[l >> 32].pack('N') + [l & 0xFFFF].pack('N')
end

def string16(s)
  return [s.length].pack('n') + Iconv.iconv("UCS-2BE", "US-ASCII", s).to_s
end

s = TCPSocket.open('localhost', 25565)

username = 'timekeeper'
s.write(0x02.chr + string16(username))
s.read(5)
protocol_version = 13
s.write(0x01.chr + int(protocol_version) + string16(username) + long(0) + 0.chr)
s.read(16)

Thread.new do
  while (true)
    puts 'heartbeat'
    s.write(0x00.chr)
    sleep(10)
  end
end

while (true)
  s.read()
end
