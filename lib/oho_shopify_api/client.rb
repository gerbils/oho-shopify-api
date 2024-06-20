require "graphql/client"
require "graphql/client/http"

SCHEMA_FILE = "/tmp/shopify_schema.json"

module OhoShopifyApi

  # general helper
  def self.convert_dtm(dtm)
    dtm.strftime("%F")
  end

  module Private
    HTTP = GraphQL::Client::HTTP.new("https://#{ENV['SHOPIFY_STORE']}/admin/api/2024-01/graphql.json") do
      def headers(context)
        {
          "Content-Type": "application/json",
          'X-Shopify-Access-Token': ENV["SHOPIFY_TOKEN"] || fail("source set_env")
        }
      end
    end

    unless File.exist? SCHEMA_FILE
      GraphQL::Client.dump_schema(HTTP, SCHEMA_FILE)
    end

    Schema = GraphQL::Client.load_schema(SCHEMA_FILE)
    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end

  STDERR.puts "\n\nConnected to shopify\n\n"

  Client = Private::Client
end

