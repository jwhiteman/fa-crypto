require "openssl"
require "base64"

txt = Base64.decode64(IO.read("input/7.txt"))
key = "YELLOW SUBMARINE"
cip = OpenSSL::Cipher.new("AES-128-ECB")

cip.decrypt
cip.key = key

puts cip.update(txt) + cip.final
