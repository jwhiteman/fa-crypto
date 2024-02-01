require "base64"

def hamming(bytes1, bytes2)
  bytes1.
    each_with_index.
    map do |byte, idx|
      xor = byte ^ bytes2[idx]

      8.times.reduce(0) do |acc, n|
        acc + ((xor >> n) & 1)
      end
    end.sum
end

def in_blocks(bytes, keysize)
  bytes.
    each_slice(keysize).
    reject { |block| block.length < keysize }
end

def keysize_score(bytes, keysize)
  blocks = in_blocks(bytes, keysize).each_cons(2).to_a

  blocks.reduce(0) do |acc, (b1, b2)|
    h1 = hamming(b1, b2)
    h2 = h1 / keysize.to_f

    acc + h2
  end / blocks.length.to_f
end

def most_likely_keysize(bytes, keyrange:)
  keyrange.map do |keysize|
    [keysize_score(bytes, keysize), keysize]
  end.min[1]
end

def score(bytes)
  bytes.pack("C*").scan(/[etaoin shrdlu]/i).length
end

def crack(bytes, keysize, keyrange:)
  in_blocks(bytes, keysize).
    transpose.
    map do |block|
      keyrange.map do |key|
        [score(block.map { |byte| byte ^ key }), key.chr]
      end.max[1]
    end.join
end

b64txt  = IO.read("input/6.txt")
txt     = Base64.decode64(b64txt)
bytes   = txt.bytes
keysize = most_likely_keysize(bytes, keyrange: 2..40)
key     = crack(bytes, keysize, keyrange: 0...127)

puts key
