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
    p1    = pad("_" * kl + msg).pack("C*")        #              stub'd-key || msg || original-padding <- what we're interested in
    s1    = [mac].pack("H*").unpack("N5")         #       state: key        || msg || original-padding

    p2    = pad(p1 + newtxt).pack("C*")           #              stub'd-key || msg || original-padding || newtxt || new-padding <- what we're interested in
    pld   = p2[p1.length..]                       #                                                       newtxt || new-padding
    h2    = sha1(pld, state: s1, is_padded: true) # forged-hash: (state ^ see above)                   || newtxt || new-padding
    fmsg  = p1[kl..] + newtxt                     # forged-msg:                msg || original-padding || newtxt  (...new-padding will be added by the server)

    if valid?(message: fmsg, mac: h2)             # ...does sha1(key || forged-msg) == forged-hash ?
      return { status: "forged!", message: fmsg, mac: h2 }
    end
  end
end

puts forge(mac, msg, ";admin=true").inspect
