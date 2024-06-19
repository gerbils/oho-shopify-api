# vim: ft=graphql
require_relative "../client"

module OhoShopifyApi::Queries; end
module OhoShopifyApi::Queries::Metaobject


Define = OhoShopifyApi::Client.parse <<-'GRAPHQL'
mutation($definition: MetaobjectDefinitionCreateInput!) {
    metaobjectDefinitionCreate(definition: $definition) {
        metaobjectDefinition {
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

FindAllTypes = OhoShopifyApi::Client.parse <<-'GRAPHQL'
{
    metaobjectDefinitions(first: 200) {
    nodes{
        id
        type
    }
  }
}
GRAPHQL


Upsert = OhoShopifyApi::Client.parse <<-'GRAPHQL'
mutation($handle: MetaobjectHandleInput!, $metaobject: MetaobjectUpsertInput!) {
  metaobjectUpsert(handle: $handle, metaobject: $metaobject) {
        metaobject {
            handle
        }
        userErrors {
            field
            message
        }
    }
}
GRAPHQL
end
