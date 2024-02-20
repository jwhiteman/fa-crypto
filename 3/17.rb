require "pry"
require "openssl"

$key = OpenSSL::Random.random_bytes(16)

PLAINTEXTS = %w(
  MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=
  MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=
  MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==
  MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==
  MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl
  MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==
  MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==
  MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=
  MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=
  MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93
)

def encrypted_message
  iv          = OpenSSL::Random.random_bytes(16)
  plaintext   = PLAINTEXTS[rand(10)].unpack1("m0")
  cip         = OpenSSL::Cipher.new("AES-128-CBC")
  cip.encrypt
  cip.key     = $key
  cip.iv      = iv

  [iv, cip.update(plaintext) + cip.final]
end

def decrypt(ciphertext, iv)
  cip         = OpenSSL::Cipher.new("AES-128-CBC")
  cip.decrypt
  cip.padding = 0
  cip.key     = $key
  cip.iv      = iv

  cip.update(ciphertext) + cip.final
end

def valid_pkcs7?(str)
  last = str[-1]

  padding_string = last * last.ord

  str[-last.ord..-1] == padding_string
end

def oracle(ciphertext, iv)
  plaintext = decrypt(ciphertext, iv)

  valid_pkcs7?(plaintext)
end

# meh...
def decrypt_last_block(iv, ciphertext, offset)
  input = iv + ciphertext[0..-1-(16 * offset)]

  (1..16).reduce([[], []]) do |(ps, ds), i|
    prefix = ds.map { |d| d ^ i }.pack("C*")
    ci     = input[-16 - i]

    cp =
      (0..255).detect do |guess|
        next if guess == ci.ord && i == 1
        input[(-16-i)..(-16-1)] = guess.chr + prefix

        oracle(input[16..-1], input[0...16])
      end

    di = cp ^ i
    pi = (di ^ ci.ord).chr

    [ps.unshift(pi), ds.unshift(di)]
  end[0].join
end

iv, c = encrypted_message

plaintext =
  (c.length / 16).times.map do |k|
    decrypt_last_block(iv, c, k)
  end.reverse.join

puts plaintext.inspect
