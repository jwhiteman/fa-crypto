require_relative "mt19937"

prng = MT19937.new(42)

640.times do
  puts prng.rand
end
