require_relative "mt19937"

def clone(prng)
  MT19937.new(0).tap do |clone|
    clone.mt = 624.times.map { untemper(prng.rand) }
  end
end

def untemper(y)
  y = y ^ (y >> 18)
  y = _untemper(y, 15, 0xEFC6_0000)
  y = _untemper(y, 7, 0x9D2C_5680)
  y = y ^ (y >> 11) ^ (y >> 22)
end

def _untemper(result, s, magic)
  mask  = (2 ** s) - 1
  iters = (32 / s.to_f).ceil
  acc   = 0
  solved_bits = result

  iters.times.each do |n|
    left        = (magic  >> s * n) & mask & solved_bits
    right       = (result >> s * n) & mask
    solved_bits = left ^ right

    acc = acc + (solved_bits << s * n)
  end

  acc
end

require "minitest/autorun"

Class.new(Minitest::Test) do
  def test_clone
    prng  = MT19937.new(rand(2 ** 32))
    clone = clone(prng)

    (624 * 2).times do
      assert_equal prng.rand, clone.rand
    end
  end
end
