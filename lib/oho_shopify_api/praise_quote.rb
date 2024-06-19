require_relative "client"
require_relative "queries/praise_quote.rb"

module ShopifyApi::PraiseQuote
  extend self

  PQ = ShopifyApi::Queries::PraiseQuote

  def create(handle, author, author_title, company, quote, book_code) 
    variables = {
      handle: handle,
      author: author,
      author_title: author_title || "",
      company: company || "",
      quote: quote,
      book_code: book_code,
    }

    raw_result = Client.query(PQ::Create, variables: variables) 
    result = raw_result.to_hash
    pp result
    errors = result["errors"] || result["data"]["metaobjectCreate"]["userErrors"]
    unless errors.empty?
      puts "Handle: #{handle}, author: #{author}"
      pp errors
      exit
    end
    sleep(0.02)
  end

end

