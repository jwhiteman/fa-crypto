def validate_pkcs7(str)
  last = str[-1]

  if last.ord > 0 && last.ord <= 16
    padding_string = last * last.ord

    str[-16..-1] =~ /#{padding_string}$/
  else
    false
  end
end

require "minitest/autorun"

Class.new(Minitest::Test) do
  def test_success
    assert validate_pkcs7("ICE ICE BABY\x04\x04\x04\x04")
  end

  def test_failure
    refute validate_pkcs7("ICE ICE BABY\x05\x05\x05\x05")
    refute validate_pkcs7("ICE ICE BABY\x01\x02\x03\x04")
  end
end
