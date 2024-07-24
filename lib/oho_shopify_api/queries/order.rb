# vim: ft=graphql

require_relative "../client"

module OhoShopifyApi::Queries; end
module OhoShopifyApi::Queries::Order

Fetch = OhoShopifyApi::Client.parse <<-GRAPHQL
fragment Amount on MoneyBag {
    shopMoney {
        amount
        currencyCode
    }
}

fragment AddressFields on MailingAddress {
    id
    name
    company
    address1
    address2
    city
    province
    zip
    provinceCode
    country
    phone
}


query($filter: String, $limit: Int, $lastCursor: String) {
    orders(query: $filter, first: $limit, after: $lastCursor) {
        pageInfo {
            hasNextPage
            endCursor
        }

        nodes {
            id
            createdAt
            updatedAt
            processedAt
            billingAddressMatchesShippingAddress
            billingAddress {
               ...AddressFields
            }
            shippingAddress {
               ...AddressFields
            }
            clientIp


            estimatedTaxes
            taxesIncluded
            name
            email
            poNumber
            cancelledAt
            discountCodes
            fullyPaid
            lineItems(first: 50) {
                nodes {
                    id
                    name
                    quantity
                    sku
                    currentQuantity
                    discountedUnitPriceAfterAllDiscountsSet {
                        ...Amount
                    }
                }
            }
            refunds(first: 20) {
                createdAt
                updatedAt
                note
                refundLineItems(first: 10) {
                    nodes {
                        priceSet {
                            ...Amount
                        }
                        quantity
                        subtotalSet {
                            ...Amount
                        }
                        totalTaxSet {
                            ...Amount
                        }
                        lineItem {
                            id
                            sku
                        }
                    }
                }
                totalRefundedSet {
                    ...Amount
                }
            }

            transactions {
                amountSet {
                    ...Amount
                }
                createdAt
                fees {
                    amount {
                        amount
                        currencyCode
                    }
                    flatFee {
                        amount
                        currencyCode
                    }
                    flatFeeName
                    rate
                    rateName
                    taxAmount {
                        amount
                        currencyCode
                    }
                    type
                }
                kind
                status
            }
            netPaymentSet {
                ...Amount
            }
            totalDiscountsSet {
                ...Amount
            }
            totalPriceSet {
                ...Amount
            }
            totalReceivedSet {
                ...Amount
            }
            totalRefundedSet {
                ...Amount
            }
            totalShippingPriceSet {
                ...Amount
            }
            totalTaxSet {
                ...Amount
            }
            totalWeight

            returns(first: 10) {
                nodes {
                    name
                    status
                    totalQuantity
                    refunds(first: 10) {
                        nodes {
                            refundLineItems(first: 10) {
                                nodes {
                                    priceSet {
                                        ...Amount
                                    }
                                    quantity
                                    subtotalSet {
                                        ...Amount
                                    }
                                    totalTaxSet {
                                        ...Amount
                                    }
                                }
                            }
                            totalRefundedSet {
                                ...Amount
                            }
                        }
                    }
                }
            }
        }
    }
}

GRAPHQL
end
