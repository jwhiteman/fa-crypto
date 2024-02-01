IO.read("input/8.txt").lines.each_with_index do |line, idx|
  blocks = line.scan(/.{32}/)

  if blocks.uniq.length < 10
    puts "ECB detected: line #{idx+1}"
  end
end
