def pkcs7(plaintext, blocksize)
  r = plaintext.length % blocksize
  n = r.zero? ? r : blocksize - r

  plaintext + Array.new(n) { n }.pack("C*")
end

puts pkcs7("YELLOW SUBMARINE", 20).inspect
