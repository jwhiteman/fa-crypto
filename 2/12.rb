require "openssl"

KEY = OpenSSL::Random.random_bytes(16)

def oracle(input)
  unknown = <<-UNKNOWN.unpack1("m")
Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
YnkK
  UNKNOWN

  cip         = OpenSSL::Cipher.new("AES-128-ECB")
  cip.encrypt
  cip.key     = KEY
  cip.update(input + unknown) + cip.final
end

def crack(blocksize, numblocks)
  known = Array.new(blocksize) { 0 }
  acc   = []

  numblocks.times.each do |n|
    (blocksize - 1).downto(0) do |m|
      input = known.take(m).join
      bytes = n*blocksize...n.succ*blocksize
      block = yield(input)[bytes]

      found =
        (0...127).detect do |byte|
          pre    = (known + acc).last(blocksize - 1).join
          output = yield(pre + byte.chr)[0..blocksize-1]
          output == block
        end

      found ? acc << found.chr : break
    end
  end

  acc.join
end

blocks = oracle("X" * 64).scan(/.{16}/)
if blocks.length > blocks.uniq.length
  puts "ECB DETECTED!!!\n\n"
  puts crack(16, oracle("").length / 16) { |input| oracle(input) }
end
