require_relative "client"
require_relative "queries/metafield.rb"

module OhoShopifyApi::Metafield
  extend self

  MF = OhoShopifyApi::Queries::Metafield
  Client = OhoShopifyApi::Client

  def define(definition)
    if lookup(definition)
      puts "Skipping #{definition[:key]}: already defined"
      return
    end
    raw_result = Client.query(MF::Create, variables: { definition: definition }) 
    result = raw_result.to_hash
    puts "Result"
    pp result
    errors = result.dig("data", "metafieldDefinitionCreate", "userErrors")
    if errors && !errors.empty?
      puts "ERROR: CreateMetafield: #{definition.inspect}"
      pp errors
      exit
    end
    sleep(0.02)
  end

  def lookup(spec)
    raw_result = Client.query(MF::Find, variables: { key: spec[:key] || fail("missing key") }) 
    result = raw_result.to_hash
    result.dig("data", "metafieldDefinitions", "edges", 0, "node") 
  end

end

