require "openssl"

input = "L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyy"\
        "MTJULu/6/kXX0KSvoOLSFQ==".unpack1("m0")
key   = "YELLOW SUBMARINE"
nonce = 0

def encrypt(key, block)
  cip         = OpenSSL::Cipher.new("AES-128-ECB")
  cip.encrypt
  cip.padding = 0
  cip.key     = key
  cip.update(block) + cip.final
end

def ctr(key, nonce, input)
  input.
    bytes.
    each_slice(16).
    map.
    with_index do |block, idx|
      keystream = encrypt(key, [nonce, idx].pack("Qq"))
      block.map.with_index do |byte, idx|
        byte ^ keystream[idx].ord
      end
    end.flatten.pack("C*")
end

puts ctr(key, nonce, ctr(key, nonce, ctr(key, nonce, input)))
