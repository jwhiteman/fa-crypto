require "openssl"

KEY = OpenSSL::Random.random_bytes(16)

def encrypt(ctext)
  cip = OpenSSL::Cipher.new("AES-128-ECB")
  cip.encrypt
  cip.key = KEY
  cip.update(ctext) + cip.final
end

def decrypt(ptext)
  cip = OpenSSL::Cipher.new("AES-128-ECB")
  cip.decrypt
  cip.key = KEY
  cip.update(ptext) + cip.final
end

def profile_for(email)
  email = email.gsub(/[=&]/, "")

  "email=#{email}&uid=10&role=user"
end

def parse_cookie(cookie)
  decrypt(cookie).
    split("&").
    reduce({}) do |acc, str|
      key, val = str.split("=")

      acc[key] = val
      acc
    end
end

def oracle(email)
  encrypt(profile_for(email))
end

payload = [
  oracle("hackr@hax.com").slice(0, 32),
  oracle("X" * 10 + "admin" + "\v" * 11).slice(16, 16)
].join

puts parse_cookie(payload).inspect
