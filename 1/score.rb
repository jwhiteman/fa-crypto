bytes = ("etaoin shrdlu".bytes + "etaoin shrdlu".upcase.bytes)

SCORE =
  bytes.reduce(Hash.new(0)) do |acc, byte|
    acc[byte] = 1
    acc
  end.freeze

def score(bytes)
  bytes.reduce(0) { |acc, byte| acc += SCORE[byte] }
end
