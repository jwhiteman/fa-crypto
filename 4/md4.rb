# adapted from https://rosettacode.org/wiki/MD4#Ruby
require "stringio"

module MD4
  extend self

  MASK = (1 << 32) - 1

  def _append(l, r)
    l + r.force_encoding("ASCII-8bit")
  end

  def pad(string)
    bit_len = string.size << 3
    string = _append(string, "\x80")
    while (string.size % 64) != 56
    string = _append(string, "\x00")
    end
    string = _append(string, [bit_len & MASK, bit_len >> 32].pack("V2"))

    if string.size % 64 != 0
      fail "failed to pad to correct length"
    else
      string
    end
  end

  def md4(string, state: nil, is_padded: false)
    # functions
    f = proc { |x, y, z| x & y | x.^(MASK) & z }
    g = proc { |x, y, z| x & y | x & z | y & z }
    h = proc { |x, y, z| x ^ y ^ z }
    r = proc { |v, s| (v << s).&(MASK) | (v.&(MASK) >> (32 - s)) }

    # initial hash
    a, b, c, d = state || [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]

    string = pad(string) unless is_padded

    io = StringIO.new(string)
    block = ""

    while io.read(64, block)
      x = block.unpack("V16")

      # Process this block.
      aa, bb, cc, dd = a, b, c, d
      [0, 4, 8, 12].each {|i|
        a = r[a + f[b, c, d] + x[i],  3]; i += 1
        d = r[d + f[a, b, c] + x[i],  7]; i += 1
        c = r[c + f[d, a, b] + x[i], 11]; i += 1
        b = r[b + f[c, d, a] + x[i], 19]
      }
      [0, 1, 2, 3].each {|i|
        a = r[a + g[b, c, d] + x[i] + 0x5a827999,  3]; i += 4
        d = r[d + g[a, b, c] + x[i] + 0x5a827999,  5]; i += 4
        c = r[c + g[d, a, b] + x[i] + 0x5a827999,  9]; i += 4
        b = r[b + g[c, d, a] + x[i] + 0x5a827999, 13]
      }
      [0, 2, 1, 3].each {|i|
        a = r[a + h[b, c, d] + x[i] + 0x6ed9eba1,  3]; i += 8
        d = r[d + h[a, b, c] + x[i] + 0x6ed9eba1,  9]; i -= 4
        c = r[c + h[d, a, b] + x[i] + 0x6ed9eba1, 11]; i += 8
        b = r[b + h[c, d, a] + x[i] + 0x6ed9eba1, 15]
      }
      a = (a + aa) & MASK
      b = (b + bb) & MASK
      c = (c + cc) & MASK
      d = (d + dd) & MASK
    end

    [a, b, c, d].pack("V4").unpack1("H*")
  end
end

if __FILE__ == $0
  require "pry"
  require "minitest/autorun"

  Class.new(Minitest::Test) do
    # https://emn178.github.io/online-tools/md4.html
    def test_parity
      assert_equal "866437cb7a794bce2b727acc0362ee27",
                   MD4.md4("hello")

      assert_equal "fa321f27939c7198a12df491b0ac200c",
                   MD4.md4("A" * 129)
    end
  end
end
