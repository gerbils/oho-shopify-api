# vim: ft=graphql
require_relative "../client"

module OhoShopifyApi::Queries; end

module OhoShopifyApi::Queries::Metafield

Find = OhoShopifyApi::Client.parse <<-'GRAPHQL'
query($key: String!) {
metafieldDefinitions(first: 1, ownerType: PRODUCT, key: $key) {
    edges {
      node {
        key
        name
      }
    }
  }
}
GRAPHQL

Create= OhoShopifyApi::Client.parse <<-'GRAPHQL'
mutation($definition: MetafieldDefinitionInput!) {
  metafieldDefinitionCreate(definition: $definition) {
    createdDefinition {
      id
      name
    }
    userErrors {
      field
      message
    }
  }
}
GRAPHQL

end

