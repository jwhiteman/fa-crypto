require "openssl"

BLOCK_SIZE = 16

class Array
  def as_string; pack("C*"); end
end

def pkcs7(plaintext, blocksize)
  r = plaintext.length % blocksize
  n = r.zero? ? r : blocksize - r

  plaintext + Array.new(n) { n }.pack("C*")
end

def encrypt(input, key)
  cip         = OpenSSL::Cipher.new("AES-128-ECB")
  cip.encrypt
  cip.key     = key
  cip.padding = 0
  cip.update(input) + cip.final
end

def cbc_encrypt(input, key, iv)
  input.
    bytes.
    each_slice(BLOCK_SIZE).
    reduce([iv.bytes, ""]) do |(prev, out), block|
      xblock = block.
                 each_with_index.
                 map { |byte, idx| byte ^ prev[idx] }

      eblock = encrypt(xblock.as_string, key)

      [eblock.bytes, out << eblock]
    end[1]
end

def encryption_oracle(input, by_chance: rand(2).zero?)
  key   = OpenSSL::Random.random_bytes(BLOCK_SIZE)
  iv    = OpenSSL::Random.random_bytes(BLOCK_SIZE)
  pre   = OpenSSL::Random.random_bytes(rand(6) + 5)
  post  = OpenSSL::Random.random_bytes(rand(6) + 5)

  input = pkcs7([pre, input, post].join, BLOCK_SIZE)

  if by_chance
    encrypt(input, key)
  else
    cbc_encrypt(input, key, iv)
  end
end

def detect_encryption
  blocks = yield.scan(/.{#{BLOCK_SIZE}}/)

  if blocks.uniq.length < blocks.length
    puts "ECB detected"
  else
    puts "CBC deduced"
  end
end

100.times do
  detect_encryption { encryption_oracle("X" * 64) }
end
