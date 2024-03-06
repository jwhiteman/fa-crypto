require "openssl"

def ctr(input, nonce, key)
  cip     = OpenSSL::Cipher.new("AES-128-CTR")
  cip.encrypt
  cip.key = key
  cip.iv  = nonce
  cip.update(input) + cip.final
end

def admin?(ciphertext, key: KEY, nonce: NONCE)
  plaintext = ctr(ciphertext, key, nonce)

  !!(plaintext =~ /;admin=true;/)
end

def comment(text, key: KEY, nonce: NONCE)
  pre   = "comment1=cooking%20MCs;userdata="
  post  = ";comment2=%20like%20a%20pound%20of%20bacon"
  input = pre + text.gsub(/[=;]/, "") + post

  ctr(input, KEY, NONCE)
end

KEY   = OpenSSL::Random.random_bytes(16)
NONCE = OpenSSL::Random.random_bytes(16)

# ATTACKING CODE:
# C  = P ⊕ K
# P  = C ⊕ K - so we'll be attacking the decrypt
# P' = C' ⊕ K

def swap(chr); (chr.ord ^ 1).chr; end

c1     = comment(":admin<true")
c1[32] = swap(c1[32])
c1[38] = swap(c1[38])
puts admin?(c1)
