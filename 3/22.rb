require_relative "mt19937"

# build a lookup from the past hour
lookup = Hash.new { |k, v| k[v] = [] }

t = Time.now.to_i
((t-3600)..t).reduce(lookup) do |lookup, seed|
  prng = MT19937.new(seed)

  # get the first thousand entries
  1000.times do
    lookup[prng.rand] << seed
  end

  lookup
end

# SERVER:
server_seed = Time.now.to_i - rand(3600)
server      = MT19937.new(server_seed)

# pretend the stream has been going on for some time...
rand(1000).times do
  server.rand
end

# ...and then we capture some value
val = server.rand

# use our lookup to crack the seed:
found = lookup.dig(val, 0)

puts "seed cracked: #{found}"
