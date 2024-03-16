require "openssl"
require "pry"

p = "ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024"\
    "e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd"\
    "3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec"\
    "6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f"\
    "24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361"\
    "c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552"\
    "bb9ed529077096966d670c354e4abc9804f1746c08ca237327fff"\
    "fffffffffffff".hex

g = 2

a = rand(p)      # alice private
A = g.pow(a, p)  # alice public

b = rand(p)      # bob private
B = g.pow(b, p)  # bob public

s1 = B.pow(a, p) # alice calculates S
s2 = A.pow(b, p) # bob calculates S

k  = OpenSSL::Digest::MD5.hexdigest(s1.to_s)
puts "a:\t#{a}\nb:\t#{b}\ns1:\t#{s1}\ns2:\t#{s2}\nk:\t#{k}"
puts s1 == s2
