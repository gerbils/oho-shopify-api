require "typhoeus"
require "json"

ACCESS_TOKEN = ENV["SHOPIFY_TOKEN"] || fail("source set-env")
STORE_NAME   = ENV["SHOPIFY_STORE"] || fail("set SHOPIFY_STORE")

def make_request(method, endpoint, params: {}, body: "")
  if body && !body.is_a?(String)
    body = body.to_json
  end

  request = Typhoeus::Request.new(
    "https://#{STORE_NAME}.myshopify.com/admin/api/2024-04/#{endpoint}",
    method: method,
    body: body,
    headers: {
      "X-Shopify-Access-Token": ACCESS_TOKEN,
      "Content-Type": "application/json",
    },
    params: params,
  )
  response = request.run

  if response.success?
    limits = response.headers["x-shopify-shop-api-call-limit"]
    if limits && limits =~ /(\d+)\/(\d+)/
      used = $1.to_i
      total = $2.to_i
      puts [used, total]
      if (total - used) < 10
        to_wait = 10 - (total-used)
        to_wait = 2**to_wait/10
        puts "Sleeping #{to_wait}s"
        sleep(to_wait)
      end
    end

    JSON.parse(response.response_body)

  elsif response.timed_out?
    fail("got a time out")
  elsif response.code == 0
    fail(response.return_message)
  else
    msg = JSON.parse(response.body)["errors"]
    pp msg
    fail("HTTP request failed: #{response.code}. #{msg["base"].join(",")}" )
  end
end

# pp make_request(:get, "products/7559789150394.json", params: { fields: "id" })
