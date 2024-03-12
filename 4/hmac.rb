require "openssl"

class Array
  def ^(other)
    raise "xor error" if length != other.length

    map.with_index { |byte, idx| byte ^ other[idx] }
  end
end

module HMAC
  extend self

  BLOCK_SIZE  = 64
  OUTPUT_SIZE = 20

  def hmac(key, msg)
    key, msg = key.bytes, msg.bytes

    block_sized_key = _compute_block_sized_key(key)
    o_key_pad       = block_sized_key ^ ([0x5c] * BLOCK_SIZE)
    i_key_pad       = block_sized_key ^ ([0x36] * BLOCK_SIZE)

    hash_bytes      = _hash(o_key_pad + _hash(i_key_pad + msg))

    hash_bytes.pack("C*").unpack1("H*")
  end

  def _compute_block_sized_key(key)
    if key.length > BLOCK_SIZE
      _hash(key)
    elsif key.length < BLOCK_SIZE
      key + [0] * (BLOCK_SIZE - key.length)
    else
      key
    end
  end

  def _hash(bytes)
    OpenSSL::Digest::SHA1.digest(bytes.pack("C*")).bytes
  end
end


if __FILE__ == $0
  require "minitest/autorun"

  Class.new(Minitest::Test) do
    def test_parity
      key = "yo"
      msg = "ma!"

      assert_equal OpenSSL::HMAC.hexdigest("SHA1", key, msg),
                   HMAC.hmac(key, msg)
    end
  end
end
