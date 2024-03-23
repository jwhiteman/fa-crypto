require "pry"
require "openssl"

def _to_key(bignum)
  OpenSSL::Digest::SHA1.hexdigest(bignum.to_s).slice(0, 16)
end

def _encrypt(msg, key, iv)
  cip     = OpenSSL::Cipher.new("AES-128-CBC")
  cip.encrypt
  cip.key = key
  cip.iv  = iv
  cip.update(msg) + cip.final
end

def _decrypt(msg, key, iv)
  cip     = OpenSSL::Cipher.new("AES-128-CBC")
  cip.decrypt
  cip.key = key
  cip.iv  = iv
  cip.update(msg) + cip.final
end

def _random_iv
  OpenSSL::Random.random_bytes(16)
end

p = "ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024"\
    "e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd"\
    "3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec"\
    "6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f"\
    "24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361"\
    "c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552"\
    "bb9ed529077096966d670c354e4abc9804f1746c08ca237327fff"\
    "fffffffffffff".hex

g = 2

# client init:
client_private_key = rand(p)
client_public_key  = g.pow(client_private_key, p)

# server init:
server_private_key = rand(p)
server_public_key  = g.pow(server_private_key, p)

# (*** mallory intercept public keys!:)
client_public_key = p
server_public_key = p

# client calculates S:
client_s = server_public_key.pow(client_private_key, p)
client_s = _to_key(client_s)

# server calculates S:
server_s = client_public_key.pow(server_private_key, p)
server_s = _to_key(server_s)

# client sends message:
iv1 = _random_iv
c1  = _encrypt("hello, world", client_s, iv1)

# (*** mallory reads client message ***)
mallory_s = _to_key(0)
msg = _decrypt(c1, mallory_s, iv1)
puts "mitm decrypts message: #{msg}"

# server reads, encrypts, echos:
msg = _decrypt(c1, server_s, iv1)
iv2 = _random_iv
c2  = _encrypt(msg, server_s, iv2)

# client receives the echo:
msg = _decrypt(c2, client_s, iv2)
