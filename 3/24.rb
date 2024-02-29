require "pry"
require_relative "mt19937"
require "openssl"

def mt19937_encrypt(input, seed)
  prng = MT19937.new(seed)

  input.
    bytes.
    each_slice(4).
    map do |block|
      keystream = [prng.rand].pack("N*").bytes

      block.map.with_index { |byte, idx| byte ^ keystream[idx] }
    end.flatten.pack("C*")
end

def crack_seed(ciphertext, known_text)
  (2 ** 16).times.detect do |seed|
    mt19937_encrypt(ciphertext, seed).include?(known_text)
  end
end

# PART 1:
seed        = rand(2 ** 16)
known_text  = "A" * 14
prefix      = OpenSSL::Random.random_bytes(6 + rand(10))
ciphertext  = mt19937_encrypt(prefix + known_text, seed)
found       = crack_seed(ciphertext, known_text)
puts "Seed cracked! #{found}"

# PART 2:
def generate_password_reset_token
  prng = MT19937.new(Time.now.to_i)

  16.times.reduce("") do |acc, _|
    acc << (prng.rand % 256).chr
  end
end

def mt19937_token?(tok)
  t = Time.now.to_i
  l = tok.length

  !!(t-20..t).detect do |seed|
    prng = MT19937.new(seed)
    str  = l.times.reduce("") do |acc, _|
             acc << (prng.rand % 256).chr
           end
    str == tok
  end
end

puts mt19937_token?(OpenSSL::Random.random_bytes(16)) # false
puts mt19937_token?(generate_password_reset_token)    # true
