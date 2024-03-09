require "pry"
require_relative "md4"

# SERVER:
def genmac(message, key: KEY)
  MD4.md4(key + message)
end

def valid?(message:, mac:)
  !!(genmac(message) == mac)
end

KEY = "some shitty key"
msg = "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon"
mac = genmac(msg)

# ATTACKER:
# - server:    mac  = key ||  msg || padding
# - attacker:         (state)                 || newtxt
# - server:           key ||  msg || padding  || newtxt  || (newpadding <- added by server)
# -    ...:                  [msg || padding  || newtxt] <- payload
# - attacker:  fmac = (state)                 || newtxt  || newpadding

kl         = 15
keystub    = "_" * kl
newtxt     = ";admin=true"
state      = [mac].pack("H*").unpack("V4")
padding    = MD4.pad(keystub + msg)[(keystub + msg).length..]
newpadding = MD4.pad(keystub + msg + padding + newtxt)
newpadding = newpadding[(keystub + msg + padding + newtxt).length..]

fmac       = MD4.md4(newtxt + newpadding, state: state, is_padded: true)
fmsg       = msg + padding + newtxt

puts valid?(message: fmsg, mac: fmac)
