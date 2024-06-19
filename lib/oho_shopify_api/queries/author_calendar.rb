# vim: ft=graphql
require_relative "../client"

module OhoShopifyApi::Queries; end

module OhoShopifyApi::Queries::AuthorCalendar

GetLastUpdate = OhoShopifyApi::Client.parse <<-'GRAPHQL'
query {
  metaobjectByHandle(handle: {
    type: "author-calendar-updated-at",
    handle: "singleton"
  }) {
    updated_at: field(key: "updated_at") { value }
  }
}
GRAPHQL

SetLastUpdate = OhoShopifyApi::Client.parse <<-'GRAPHQL'
mutation($handle: MetaobjectHandleInput!, $metaobject: MetaobjectUpsertInput!) {
  metaobjectUpsert(handle: $handle, metaobject: $metaobject) {
    metaobject {
      handle
      updated_at: field(key: "updated_at") { value }
    }
    userErrors {
      field
      message
      code
    }
  }
}
GRAPHQL

UpsertItem = OhoShopifyApi::Client.parse <<-'GRAPHQL'
mutation($handle: MetaobjectHandleInput!, $metaobject: MetaobjectUpsertInput!) {
  metaobjectUpsert(handle: $handle, metaobject: $metaobject) {
    metaobject {
      handle
    }
    userErrors {
        field
        message
        code
    }
  }
}
GRAPHQL

end

