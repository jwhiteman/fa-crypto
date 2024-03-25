require "pry"
require "openssl"

def sha(t); OpenSSL::Digest::SHA256.hexdigest(t); end

context = {
  N: "ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024"\
     "e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd"\
     "3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec"\
     "6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f"\
     "24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361"\
     "c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552"\
     "bb9ed529077096966d670c354e4abc9804f1746c08ca237327fff"\
     "fffffffffffff".hex,
  g: 2,
  k: 3,
  I: "email@email.com", # pretend the server only knows about 1 user...
  P: "somep4ssw0rd"
}.freeze

# server
salt  = rand(2 ** 32).to_s(16)
xh    = sha(salt + context[:P])
x     = xh.hex

g     = context[:g]
n     = context[:N]
v     = g.pow(x, n)

# client
g     = context[:g]
n     = context[:N]
a     = rand(n)
req   = { I: "email@email.com", A: g.pow(a, n) }

# server
b     = rand(n)
k     = context[:k]
res   = { salt: salt, B: k*v + g.pow(b, n) }

# both
uH    = sha(req[:A].to_s + res[:B].to_s)
u     = uH.hex

# client
xh    = sha(res[:salt] + context[:P])
x     = xh.hex
cs    = (res[:B] - k * g.pow(x, n)).pow(a + u * x, n)
ck    = sha(cs.to_s)

# server
ss    = (req[:A] * v.pow(u, n)).pow(b, n)
sk    = sha(ss.to_s)

# client
digest = OpenSSL::Digest.new("sha256")
req    = OpenSSL::HMAC.hexdigest(digest, ck, res[:salt])

# server
digest = OpenSSL::Digest.new("sha256")
if req == OpenSSL::HMAC.hexdigest(digest, sk, salt)
  puts "OK"
end
