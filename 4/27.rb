require "pry"
require "openssl"

class InvalidASCII < StandardError; end

def encrypt_url(text, key: KEY, iv: IV)
  pre     = "comment1=cooking%20MCs;userdata="
  post    = ";comment2=%20like%20a%20pound%20of%20bacon"
  cip     = OpenSSL::Cipher.new("AES-128-CBC")
  cip.encrypt
  cip.key = key
  cip.iv  = iv
  cip.update([pre, text, post].join) + cip.final
end

def admin?(ciphertext, key: KEY, iv: IV)
  cip         = OpenSSL::Cipher.new("AES-128-CBC")
  cip.decrypt
  cip.key     = key
  cip.iv      = iv
  cip.padding = 0
  plaintext   = cip.update(ciphertext)  + cip.final

  if plaintext.bytes.any? { _1 > 126 }
    raise InvalidASCII, plaintext
  else
    !!(plaintext =~ /;admin=true;/)
  end
end

KEY = OpenSSL::Random.random_bytes(16)
IV  = KEY

c   = encrypt_url("A" * 16)
c1  = c.slice(0, 16)
c3  = c.slice(32, 16)

begin
  admin?(c1 + "\x00" * 16 + c1)
rescue InvalidASCII => e
  msg = e.message
  p1  = msg.slice(0, 16)
  p3  = msg.slice(32, 16)
  key = p1.bytes.zip(p3.bytes).map { |b1, b3| b1 ^ b3 }.pack("C*")

  puts "success" if key == KEY
end
