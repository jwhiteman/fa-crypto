require "openssl"
require "pry"

def ctr(key, nonce, input)
  cip = OpenSSL::Cipher.new("AES-128-CTR")
  cip.encrypt
  cip.key = key
  cip.iv = [nonce, nonce].pack("QQ")
  cip.update(input) + cip.final
end

def score(str)
  pos = str.scan(/[etaoin shrdlu]/i).length
  neg = str.scan(/[\^~@]|[[:cntrl:]]/).length * 2 # this is dumb, but ok...

  pos - neg
end

KEY   = OpenSSL::Random.random_bytes(16)
NONCE = rand(2 ** 64)

ciphertexts =
  IO.read("input/20.txt").
  lines.
  map do |pt|
    ctr(KEY, NONCE, pt.chomp.unpack1("m0")).bytes
  end

keysize =
  ciphertexts.min_by { |c| c.length }.length

CIPHERTEXTS =
  ciphertexts.map { |ct| ct.take(keysize) }.freeze

key =
  CIPHERTEXTS.
    transpose.
    map do |bytes|
      (0..255).map do |keybyte|
        [score(bytes.map { |byte| byte ^ keybyte }.pack("C*")), keybyte]
      end.max[1]
    end

res=
  CIPHERTEXTS.
    map do |ct|
      ct.map.with_index { |byte, index| byte ^ key[index] }.pack("C*")
    end

puts res
