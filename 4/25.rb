require "pry"
require "openssl"

def encrypt(key, block)
  cip         = OpenSSL::Cipher.new("AES-128-ECB")
  cip.encrypt
  cip.padding = 0
  cip.key     = key
  cip.update(block) + cip.final
end

def ctr(key, nonce, input, block_offset: 0)
  input.
    bytes.
    each_slice(16).
    map.
    with_index do |block, idx|
      idx = idx + block_offset
      keystream = encrypt(key, [nonce, idx].pack("Qq"))
      block.map.with_index do |byte, idx|
        byte ^ keystream[idx].ord
      end
    end.flatten.pack("C*")
end

def edit(ciphertext, key, offset, newtext)
  ciphertext   = ciphertext.dup
  block_offset = offset / 16
  byte_offset  = offset % 16
  input        = ("\x00" * byte_offset) + newtext
  update       = ctr(key, $nonce, input, block_offset: block_offset)

  update[byte_offset..].
    bytes.
    each.
    with_index do |byte, idx|
      ciphertext[offset + idx] = byte.chr
    end

  ciphertext
end

# prelim:
input      = IO.read("input/25.txt").unpack1("m")
cip        = OpenSSL::Cipher.new("AES-128-ECB")
cip.decrypt
cip.key    = "YELLOW SUBMARINE"
input      = cip.update(input) + cip.final

# server:
key        = OpenSSL::Random.random_bytes(16)
$nonce     = rand(2 ** 32)
ciphertext = ctr(key, $nonce, input)

# attacker:
# p1 ⊕ k = c1
# p2 ⊕ k = c2
#      k = c2 ⊕ p2
p2 = "\x00" * ciphertext.length
c2 = edit(ciphertext, key, 0, p2)
k  = c2.bytes.zip(p2.bytes).map { |(b1, b2)| b1 ^ b2 }
p1 = ciphertext.bytes.zip(k).map { |(b1, b2)| b1 ^ b2 }.pack("C*")
puts p1
