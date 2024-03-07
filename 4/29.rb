require "openssl"
require_relative "sha1"

# SERVER
def genmac(message, key: KEY)
  OpenSSL::Digest::SHA1.hexdigest(key + message)
end

def valid?(message:, mac:)
  !!(genmac(message) == mac)
end

KEY = "some shitty key"
msg = "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon"
mac = genmac(msg)

# ATTACKER
def forge(mac, msg, newtxt)
  1.upto(32) do |kl|
    p1    = pad("_" * kl + msg).pack("C*")
    s1    = [mac].pack("H*").unpack("N5")

    p2    = pad(p1 + newtxt).pack("C*")
    h2    = sha1(p2[p1.length..], state: s1, is_padded: true)
    fmsg  = p1[kl..] + newtxt

    if valid?(message: fmsg, mac: h2)
      return { status: "forged!", message: fmsg, mac: h2 }
    end
  end
end

puts forge(mac, msg, ";admin=true").inspect
