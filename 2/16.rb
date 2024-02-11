require "openssl"

KEY = OpenSSL::Random.random_bytes(16)
IV  = OpenSSL::Random.random_bytes(16)

def oracle(str)
  str     = str.gsub(/([=;])/, %q{'\1})
  prepend = "comment1=cooking%20MCs;userdata="
  append  = ";comment2=%20like%20a%20pound%20of%20bacon"

  cip = OpenSSL::Cipher.new("AES-128-CBC")
  cip.encrypt
  cip.key = KEY
  cip.iv  = IV
  cip.update(prepend + str + append) + cip.final
end

def decrypt(str)
  cip = OpenSSL::Cipher.new("AES-128-CBC")
  cip.decrypt
  cip.key = KEY
  cip.iv  = IV
  cip.update(str) + cip.final
end

def admin?(ctext)
  !!(decrypt(ctext) =~ /;admin=true/)
end

# attacking code
def swap_char(char)
  (char.ord ^ 1).chr
end

c1      = swap_char(";")
c2      = swap_char("=")
payload = "ZZZZZ#{c1}admin#{c2}true" # cheating, knowing prepend length...
ctext   = oracle("X" * 16 + payload)

ctext[32 + 5]  = swap_char(ctext[32 + 5])
ctext[32 + 11] = swap_char(ctext[32 + 11])

puts admin?(ctext)
