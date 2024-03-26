require "pry"
require "openssl"

# https://rosettacode.org/wiki/Modular_inverse#Ruby
def invmod(a, m)
  raise "NO INVERSE - #{a} and #{m} not coprime" unless a.gcd(m) == 1
  return m if m == 1
  m0, inv, x0 = m, 1, 0
  while a > 1
    inv -= (a / m) * x0
    a, m = m, a % m
    inv, x0 = x0, inv
  end
  inv += m0 if inv < 0
  inv
end

p  = OpenSSL::BN.generate_prime(256).to_i
q  = OpenSSL::BN.generate_prime(256).to_i
n  = p * q
et = (p - 1) * (q - 1)
e  = 3
d = invmod(e, et)

public_key  = [e, n]
private_key = [d, n]

def encrypt(msg, public_key)
  e, n = public_key
  m    = msg.unpack1("H*").hex

  m.pow(e, n).to_s(16)
end

def decrypt(cip, private_key)
  d, n = private_key
  c    = cip.hex

  [c.pow(d, n).to_s(16)].pack("H*")
end

c1 = encrypt("do you know what it means to miss new orleans?", public_key)
puts c1
p1 = decrypt(c1, private_key)
puts p1
