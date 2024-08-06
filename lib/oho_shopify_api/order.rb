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
  # to the given block.
  #
  # This is gnarlier than it should be.
  #
  # Shopify updatedBy is rounded to the second, but internsally it must have more accurary.
  #
  # When we fetch new orders, we ask for those with sn updatedAt > that of the last order we
  # processed previously. However, that typically results it at least one duplicate being returned
  # at the start of the response: the the order was updated at 12:34:56.3, we ask for orders
  # updated after 12:34:56, and hence get it again.
  #
  # So, when we fetch orders, we pass them one at a time to the callback code, and it determines
  # if that order is a duplicate. If so, we don't decrement the count of orders processed
  #
  # For efficiency we download from shopify in batches using a cursor. Normally you'd
  # stop making requests when the quest returns hasNextPage=false. We can't do that
  # because if we initially asked for 10 orders, then the response would say "here's all 10, no
  # next page." But if we skipped 2 orders we have to ignore that and go fetch another 2 using
  # the cursor of the last order previously fetched

  def from_filter(max_to_fetch, filter, &callback)
    puts "top of from_filter: #{max_to_fetch} #{filter}"
    pageInfo = {}
    cursor = nil
    error_seen = false
    left_to_fetch = (max_to_fetch.zero? ? 9999999 : max_to_fetch)

    begin
      count = [left_to_fetch, ORDERS_PER_FETCH].min
      need_additional = false

      variables = {
        filter: filter,
        limit:   count,
        lastCursor: cursor
      }

      puts("Fetching orders with parameters: #{variables.inspect}")
      raw_result = OhoShopifyApi::Client.query(OhoShopifyApi::Queries::Order::Fetch, variables:)
      result   = raw_result.to_hash
      response = result["data"]["orders"]
      pageInfo = response["pageInfo"]
      # cursor   = pageInfo["endCursor"]
      orders   = response["edges"]
      orders.each do |edge|
        o = edge["node"]
        cursor = edge["cursor"]
        pp([ o["name"], cursor ])
        status = callback.call(o)
        case status
        when :error
          error_seen = true
        when :ok
          left_to_fetch -= 1
        when :restart_after_current
          need_additional = true
          puts "skipping"
        end
      end
      puts "end of loop, #{need_additional}: #{left_to_fetch} #{cursor}"
    end while !error_seen && left_to_fetch > 0 && (need_additional || pageInfo["hasNextPage"])
      puts "**** exit from_filter"
  end

end
