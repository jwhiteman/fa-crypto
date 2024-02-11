require "openssl"

KEY = OpenSSL::Random.random_bytes(16)
PRE = OpenSSL::Random.random_bytes(rand(128))

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
  cip.update(PRE + input + unknown) + cip.final
end

def calculate_topoff_bytes
  48.times do |j|
    res = oracle "X" * j
    nb  = res.length / 16

    nb.times do |k|
      if res.slice(16 * k, 16) == res.slice(16 * k.succ, 16)
        return j % 16, k
      end
    end
  end
end

def crack(num_topoff_bytes, num_prefix_blocks, numblocks)
  known = Array.new(16) { 0 }
  acc   = []
  pre   = "T" * num_topoff_bytes

  numblocks.times.each do |n|
    15.downto(0) do |m|
      input = pre + known.take(m).join
      sidx  = (num_prefix_blocks + n) * 16
      saved = oracle(input).slice(sidx, 16)

      found =
        (0..127).detect do |byte|
          mid  = (known + acc).last(15).join
          tidx = num_prefix_blocks * 16
          out  = oracle(pre + mid + byte.chr).slice(tidx, 16)

          out == saved
        end

      found ? acc << found.chr : break
    end
  end

  acc.join
end

num_topoff_bytes, num_prefix_blocks = calculate_topoff_bytes
numblocks = (oracle("").length / 16) - num_prefix_blocks
puts crack(num_topoff_bytes, num_prefix_blocks, numblocks)
