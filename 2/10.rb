require "openssl"

BLOCK_SIZE = 16

def decrypt(input, key)
  input       = input.pack("C*")
  cip         = OpenSSL::Cipher.new("AES-128-ECB")
  cip.decrypt
  cip.key     = key
  cip.padding = 0
  output      = cip.update(input) + cip.final
  output.bytes
end

def decrypt_cbc(tbytes, key, ivbytes)
  tbytes.
    each_slice(BLOCK_SIZE).
    reduce([ivbytes, ""]) do |(prev, out), block|
      out << decrypt(block, key).
               each_with_index.
               map { |byte, idx| byte ^ prev[idx] }.
               pack("C*")

      [block, out]
    end[1]
end

txt = IO.read("input/10.txt").unpack1("m")
key = "YELLOW SUBMARINE"
iv  = "\x00" * 16

puts decrypt_cbc(txt.bytes, key, iv.bytes)
