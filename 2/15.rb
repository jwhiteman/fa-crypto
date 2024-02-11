def validate_pkcs7(block)
  last_block   = block.slice(-16, 16)
  saved        = []
  padding_char = nil

  (0..15).each do |idx|
    char = last_block[idx]
    if padding_char
      char == padding_char || raise("pkcs7 padding error")
    else
      if char.ord < 16 && char.ord == 16 - idx
        padding_char = char
      elsif char == "\n" && idx == 15
        saved << char
      elsif char.ord < 16
        raise("pkcs7 padding error")
      else
        saved << char
      end
    end
  end

  saved.join
end

require "minitest/autorun"

Class.new(Minitest::Test) do
  def test_success
    assert_equal "ICE ICE BABY",
                 validate_pkcs7("ICE ICE BABY\x04\x04\x04\x04")

    assert_equal "DOLLA DOLLA BIL\n",
                 validate_pkcs7("DOLLA DOLLA BIL\n")
  end

  def test_failure
    assert_raises(RuntimeError) do
      validate_pkcs7("ICE ICE BABY\x05\x05\x05\x05")
    end

    assert_raises(RuntimeError) do
      validate_pkcs7("ICE ICE BABY\x01\x02\x03\x04")
    end
  end
end
