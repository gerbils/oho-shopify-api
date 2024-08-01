require_relative "./queries/order.rb"

ORDERS_PER_FETCH = 20


# module Sapi; end
module OhoShopifyApi::Order
  extend self

  # Return a count of orders matchiung a filter
  # to the given block. Return the final cursor so we can continue where
  # we left off next time
  def count(filter)
      variables = {
        filter: filter,
        limit:  999,
      }
      # Rails.logger.info("Counting orders with parameters: #{variables.inspect}")
      raw_result = OhoShopifyApi::Client.query(OhoShopifyApi::Queries::Order::Count, variables:)
      result   = raw_result.to_hash
      result["data"]#["ordersCount"]["count"]
  end

  # Download all orders since the given datetime, yielding each in turn
  # to the given block. Return the final cursor so we can continue where
  # we left off next time
  def from_filter(max_to_fetch, filter, &callback)
    pageInfo = {}
    cursor = nil
    error_seen = false
    left_to_fetch = (max_to_fetch.zero? ? 9999999 : max_to_fetch)

    begin
      count = [left_to_fetch, ORDERS_PER_FETCH].min
      variables = {
        filter: filter,
        limit:   count,
        lastCursor: cursor
      }
      # Rails.logger.info("Fetching orders with parameters: #{variables.inspect}")
      raw_result = OhoShopifyApi::Client.query(OhoShopifyApi::Queries::Order::Fetch, variables:)
      result   = raw_result.to_hash
      response = result["data"]["orders"]
      pageInfo = response["pageInfo"]
      cursor   = pageInfo["endCursor"]
      orders   = response["nodes"]
      orders.each do |o|
        pp(o["name"])
        if not callback.call(o)
          error_seen = true
          break
        end
        left_to_fetch -= 1
      end
    end while !error_seen && left_to_fetch > 0 && pageInfo["hasNextPage"]
  end

end

