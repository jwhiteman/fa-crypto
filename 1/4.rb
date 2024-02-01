def score(bytes)
  bytes.pack("C*").scan(/[etaoin shrdlu]/i).length
end

lines = IO.read("input/4.txt").chomp.lines

_, key, line =
  lines.each_with_index.map do |line, idx|
    bytes = [line].pack("H*").bytes

    score, key =
      (0..127).map do |k|
        [score(bytes.map { |b| b ^ k }), k]
      end.max

    [score, key, idx.succ]
  end.max

puts "Line #{line} has been xor encrypted with keybyte #{key}"
