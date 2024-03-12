require "pry"
require "httparty"

def request(msg, mac, byte)
  t = Time.now

  HTTParty.get("http://localhost:4567/test",
               query: { file: msg, signature: mac + sprintf("%02x", byte) })

  [Time.now - t, byte]
end

msg         = "foo"
found_bytes = []
byte_space  = 0..255

# for testing...
puts "trying to match:\tf7a7ada52814be244491bdf99c4a8bf0c500c163"

def to_hex(bytes) bytes.pack("C*").unpack1("H*"); end

20.times do
  found_byte =
    byte_space.map do |byte|
      request(msg, to_hex(found_bytes), byte)
    end.max[1]

  found_bytes << found_byte
  puts "byte found:\t\t#{to_hex(found_bytes)}"
end
