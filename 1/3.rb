require_relative "score"

input  = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
cbytes = [input].pack("H*").bytes

(0...127).each_with_index.map do |key, idx|
  [score(cbytes.map { |cbyte| cbyte ^ key}), idx]
end.max[1]
