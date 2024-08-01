require "graphql/client"
require "graphql/client/http"

SCHEMA_FILE = "/tmp/shopify_schema.json"

SHOPIFY_STORE = ENV["SHOPIFY_STORE"]
    # if defined? Rails && defined? Rails.application1credentials
    #               Rails.application.credentials.dig(:shopify, :store)
    #             else
    #             end

SHOPIFY_TOKEN = ENV["SHOPIFY_TOKEN"]
  # if defined? Rails && defined? Rails.credentials
  #                 Rails.application.credentials.dig(:shopify, :token)
  #               else
  #                 ENV["SHOPIFY_TOKEN"]
  #               end

unless SHOPIFY_STORE && SHOPIFY_TOKEN
  fail("set SHOPIFY_STORE and _TOKEN in environment or credentials")
end

module OhoShopifyApi

  # general helper
  def self.convert_date(dtm)
    dtm.strftime("%F")
  end

  def self.convert_dtm(dtm)
    dtm.strftime("%FT%T")
  end

  module Private
    HTTP = GraphQL::Client::HTTP.new("https://#{ENV['SHOPIFY_STORE']}/admin/api/2024-04/graphql.json") do
      def headers(context)
        {
          "Content-Type": "application/json",
          'X-Shopify-Access-Token': SHOPIFY_TOKEN,
        }
      end
    end

    # If the schema becomes outdated, the load fails with BadRequest, so we blow it away
    schema = if File.exist? SCHEMA_FILE
      begin
        STDERR.puts "Loading cached schema"
        GraphQL::Client.load_schema(SCHEMA_FILE)
      rescue KeyError
        STDERR.puts "Cached schema failed..."
        File.unlink(SCHEMA_FILE)
        nil
      end
    end

    if !schema
      STDERR.puts "Loading schema from SHOPIFY"
      schema = GraphQL::Client.load_schema(HTTP).tap do
        STDERR.puts "Caching downloaded schema"
        GraphQL::Client.dump_schema(HTTP, SCHEMA_FILE)
      end
    end

    Schema = schema
    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end

  Client = Private::Client
end

