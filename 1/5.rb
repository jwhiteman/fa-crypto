bytes = <<~INPUT.bytes
Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal
INPUT

key  = "ICE".bytes
klen = key.length

bytes.each_with_index.map do |byte, idx|
  byte ^ key[idx % klen]
end.pack("C*").unpack1("H*")
