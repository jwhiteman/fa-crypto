require "openssl"
require "pry"

def _encrypt(key, block)
  cip         = OpenSSL::Cipher.new("AES-128-ECB")
  cip.encrypt
  cip.padding = 0
  cip.key     = key
  cip.update(block) + cip.final
end

def ctr(key, nonce, input)
  input.
    bytes.
    each_slice(16).
    map.
    with_index do |block, idx|
      keystream = _encrypt(key, [nonce, idx].pack("Qq"))
      block.map.with_index do |byte, idx|
        byte ^ keystream[idx].ord
      end
    end.flatten.pack("C*")
end

KEY   = "DOLLA DOLLA BILL".freeze # cheating here
NONCE = 0

CIPHERTEXTS = %w(
  SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==
  Q29taW5nIHdpdGggdml2aWQgZmFjZXM=
  RnJvbSBjb3VudGVyIG9yIGRlc2sgYW1vbmcgZ3JleQ==
  RWlnaHRlZW50aC1jZW50dXJ5IGhvdXNlcy4=
  SSBoYXZlIHBhc3NlZCB3aXRoIGEgbm9kIG9mIHRoZSBoZWFk
  T3IgcG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==
  T3IgaGF2ZSBsaW5nZXJlZCBhd2hpbGUgYW5kIHNhaWQ=
  UG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==
  QW5kIHRob3VnaHQgYmVmb3JlIEkgaGFkIGRvbmU=
  T2YgYSBtb2NraW5nIHRhbGUgb3IgYSBnaWJl
  VG8gcGxlYXNlIGEgY29tcGFuaW9u
  QXJvdW5kIHRoZSBmaXJlIGF0IHRoZSBjbHViLA==
  QmVpbmcgY2VydGFpbiB0aGF0IHRoZXkgYW5kIEk=
  QnV0IGxpdmVkIHdoZXJlIG1vdGxleSBpcyB3b3JuOg==
  QWxsIGNoYW5nZWQsIGNoYW5nZWQgdXR0ZXJseTo=
  QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=
  VGhhdCB3b21hbidzIGRheXMgd2VyZSBzcGVudA==
  SW4gaWdub3JhbnQgZ29vZCB3aWxsLA==
  SGVyIG5pZ2h0cyBpbiBhcmd1bWVudA==
  VW50aWwgaGVyIHZvaWNlIGdyZXcgc2hyaWxsLg==
  V2hhdCB2b2ljZSBtb3JlIHN3ZWV0IHRoYW4gaGVycw==
  V2hlbiB5b3VuZyBhbmQgYmVhdXRpZnVsLA==
  U2hlIHJvZGUgdG8gaGFycmllcnM/
  VGhpcyBtYW4gaGFkIGtlcHQgYSBzY2hvb2w=
  QW5kIHJvZGUgb3VyIHdpbmdlZCBob3JzZS4=
  VGhpcyBvdGhlciBoaXMgaGVscGVyIGFuZCBmcmllbmQ=
  V2FzIGNvbWluZyBpbnRvIGhpcyBmb3JjZTs=
  SGUgbWlnaHQgaGF2ZSB3b24gZmFtZSBpbiB0aGUgZW5kLA==
  U28gc2Vuc2l0aXZlIGhpcyBuYXR1cmUgc2VlbWVkLA==
  U28gZGFyaW5nIGFuZCBzd2VldCBoaXMgdGhvdWdodC4=
  VGhpcyBvdGhlciBtYW4gSSBoYWQgZHJlYW1lZA==
  QSBkcnVua2VuLCB2YWluLWdsb3Jpb3VzIGxvdXQu
  SGUgaGFkIGRvbmUgbW9zdCBiaXR0ZXIgd3Jvbmc=
  VG8gc29tZSB3aG8gYXJlIG5lYXIgbXkgaGVhcnQs
  WWV0IEkgbnVtYmVyIGhpbSBpbiB0aGUgc29uZzs=
  SGUsIHRvbywgaGFzIHJlc2lnbmVkIGhpcyBwYXJ0
  SW4gdGhlIGNhc3VhbCBjb21lZHk7
  SGUsIHRvbywgaGFzIGJlZW4gY2hhbmdlZCBpbiBoaXMgdHVybiw=
  VHJhbnNmb3JtZWQgdXR0ZXJseTo=
  QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=
).map do |pt|
  ctr(KEY, NONCE, pt.unpack1("m0")).bytes
end

def bytes(range)
  lookup = Hash.new { |h, k| h[k] = [] }

  CIPHERTEXTS.map { |c| c[range] }
end

# inspect what bytes are most common for a particular index...
# https://www3.nd.edu/~busiforc/handouts/cryptography/Letter%20Frequencies.html
def table(range)
  lookup = Hash.new { |h, k| h[k] = [] }

  bytes(range).
    reduce(lookup) do |lookup, byte|
      lookup[byte] << byte
      lookup
    end
end

def guess(index:, byte:, is:)
  keystream_byte = byte ^ is.ord

  puts bytes(index).map { |b| (b ^ keystream_byte).chr }.join.inspect

  keystream_byte
end

key = []

key << guess(index: 0,  byte: 51,   is: "T")
key << guess(index: 1,  byte: 160,  is: "e")
key << guess(index: 2,  byte: 244,  is: " ")
key << guess(index: 3,  byte: 113,  is: "s")
key << guess(index: 4,  byte: 210,  is: " ")
key << guess(index: 5,  byte: 240,  is: "o")
key << guess(index: 6,  byte: 137,  is: " ")
key << guess(index: 7,  byte: 17,   is: "e")
key << guess(index: 8,  byte: 25,   is: "e")
key << guess(index: 9,  byte: 148,  is: "t")
key << guess(index: 10, byte: 254,  is: " ")
key << guess(index: 11, byte: 120,  is: " ")
key << guess(index: 12, byte: 59,   is: " ")
key << guess(index: 13, byte: 253,  is: " ")
key << guess(index: 14, byte: 3,    is: "e")
key << guess(index: 15, byte: 195,  is: " ")
key << guess(index: 16, byte: 26,   is: " ")
key << guess(index: 17, byte: 193,  is: " ")
key << guess(index: 18, byte: 240,  is: " ")
key << guess(index: 19, byte: 110,  is: " ")

# 1. stopping at 20 bytes because this is so tedious
# 2. who knew that " " was so common?

CIPHERTEXTS.each do |c|
  puts key.map.with_index { |kb, idx| kb ^ c[idx] }.pack("C*")
end
