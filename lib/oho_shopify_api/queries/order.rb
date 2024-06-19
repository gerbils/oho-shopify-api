# vim: ft=graphql
require_relative "../client"

module OhoShopifyApi::Queries

Order = OhoShopifyApi::Client.parse <<-'GRAPHQL'
mutation($handle: String!, $author: String!, $author_title: String!, $company: String!, $quote: String!, $book_code: String!) {
  metaobjectCreate(metaobject: {
    type: "praise_quote",
    handle: $handle,
    capabilities: {
        publishable: {
            status: ACTIVE
        }
    },
    fields: [
      { key: "author",       value: $author },
      { key: "author_title", value: $author_title },
      { key: "company",      value: $company },
      { key: "quote",        value: $quote }
      { key: "book_code",    value: $book_code }
    ]
  }) {
    userErrors {
      message
    }
  }
}
GRAPHQL

end
