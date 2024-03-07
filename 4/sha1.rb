# https://rosettacode.org/wiki/SHA-1
require "stringio"

MASK = 0xffffffff

def pad(string)
  bit_len = string.size << 3
  strb    = string.bytes
  strb    << 128
  while (strb.size % 64) != 56
    strb << 0
  end
  strb += [bit_len >> 32, bit_len & MASK].pack("N2").bytes # TODO: still creating a string here...

  if strb.size % 64 != 0
    fail "failed to pad to correct length"
  else
    strb
  end
end

def sha1(string, state: nil, is_padded: false)
  # functions and constants
  s = proc{|n, x| ((x << n) & MASK) | (x >> (32 - n))}
  f = [
    proc {|b, c, d| (b & c) | (b.^(MASK) & d)},
    proc {|b, c, d| b ^ c ^ d},
    proc {|b, c, d| (b & c) | (b & d) | (c & d)},
    proc {|b, c, d| b ^ c ^ d},
  ].freeze
  k = [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6].freeze

  # normal iv
  h = state || [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]

  strb =
    if is_padded
      string.bytes
    else
      pad(string)
    end

  # break into chunks of 64 bytes, and convert to array of 32-bit nums
  # ...and use those to create the new h/state:
  (strb.length / 64).times.map do |idx|
    bytes = strb[idx*64...idx.succ*64]
    w     = bytes.each_slice(4).map { |(a, b, c, d)| (a << 24) + (b << 16) + (c << 8) + d}

    (16..79).each {|t| w[t] = s[1, w[t-3] ^ w[t-8] ^ w[t-14] ^ w[t-16]]}

    a, b, c, d, e = h
    t = 0
    4.times do |i|
      20.times do
        temp = (s[5, a] + f[i][b, c, d] + e + w[t] + k[i]) & MASK
        a, b, c, d, e = temp, a, s[30, b], c, d
        t += 1
      end
    end

    [a,b,c,d,e].each_with_index {|x,i| h[i] = (h[i] + x) & MASK}
  end

  h.pack("N5").unpack1("H*")
end

if __FILE__ == $0
  require "openssl"
  require "minitest/autorun"
  Class.new(Minitest::Test) do
    def test_parity
      msg     = OpenSSL::Random.random_bytes(10 + rand(1000))

      assert_equal OpenSSL::Digest::SHA1.hexdigest(msg), sha1(msg)
    end
  end
end
