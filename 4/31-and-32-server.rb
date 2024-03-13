require "pry"
require_relative "hmac"
require "sinatra"

KEY = "some key".freeze

# f:  2 * amt
# f7: 3 * amt
def _insecure_compare(their_hmac, our_hmac)
  our_hmac.bytes.zip(their_hmac.bytes).all? do |b1, b2|
    sleep 0.003

    b1 == b2
  end
end

get "/test" do
  file       = params[:file]
  their_hmac = params[:signature]
  our_hmac   = HMAC.hmac(KEY, file)

  if _insecure_compare(their_hmac, our_hmac)
    "OK"
  else
    halt 500
  end
end
