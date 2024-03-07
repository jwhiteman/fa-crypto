require "pry"
require "openssl"
require_relative "sha1"

def genmac(message, key: KEY)
  SHA1.hexdigest(key + message)
end

def valid?(message:, mac:)
  genmac(message) == mac
end

KEY = OpenSSL::Random.random_bytes(16).unpack1("H*")
mac = genmac("yolo!")

puts valid?(message: "yolo!", mac: mac)
puts valid?(message: "yolo!", mac: "\x00")
