require 'net/http'

class OrdersController < ApplicationController

  SHOPIFY_BASE_URL = 'https://reallyuniquestore.myshopify.com'.freeze
  KLAVIYO_TRACK_URL = 'https://a.klaviyo.com/api/track'.freeze

  def sync
    update_klaviyo
    render json: { "orders_processed": shopify_orders.map { |order| order[:properties][:OrderId] } }
  end

  def shopify_orders
    @orders ||= begin
      url = "#{SHOPIFY_BASE_URL}/admin/api/2021-07/orders.json?status=any&financial_status=paid"
      url << "&created_at_min=#{since}" if since
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request.basic_auth ENV['SHOPIFY_API_KEY'], ENV['SHOPIFY_API_PASSWORD']
      response = http.request(request)

      orders = JSON.parse(response.body)['orders']
      orders.map { |order| shopify_to_klaviyo_order(Hashie::Mash.new(order)) }
    end
  end

  def update_klaviyo
    # placed order
    shopify_orders.each do |order|
      body_h = { "token": ENV['KLAVIYO_PUBLIC_KEY'], "event": "Placed Order" }.merge(order)
      call_klaviyo_track_api(body_h)
    end

    # ordered product
    shopify_orders.each do |order|
      order[:properties][:Items].each do |item|
        product_body =
          {
            "token": ENV['KLAVIYO_PUBLIC_KEY'],
            "event": "Ordered Product",
            "customer_properties": {
              "$email": order[:customer_properties][:$email],
              "$first_name": order[:customer_properties][:$first_name],
              "$last_name": order[:customer_properties][:$last_name]
            },
            "properties": {
              "$event_id": "#{order[:properties][:OrderId]}_#{item[:SKU]}",
              "$value": 9.99,
              "OrderId": order[:properties][:OrderId],
              "ProductID": item[:ProductID],
              "SKU": item[:SKU],
              "ProductName": item[:ProductName],
              "Quantity": item[:Quantity]
            },
            "time": order[:time]
          }

        call_klaviyo_track_api(product_body)
      end
    end
  end

  def call_klaviyo_track_api(body_h)
    uri = URI(KLAVIYO_TRACK_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Accept"] = 'text/html'
    request["Content-Type"] = 'application/x-www-form-urlencoded'
    request.body = "data=#{CGI.escape(body_h.to_json)}"
    response = http.request(request)
  end

  def shopify_to_klaviyo_order(order)
    {
      "customer_properties": {
        "$email": order.customer.email,
        "$first_name": order.customer.first_name,
        "$last_name": order.customer.last_name,
        "$phone_number": order.customer.phone,
        "$address1": order.customer.default_address.address1,
        "$address2": order.customer.default_address.address2,
        "$city": order.customer.default_address.city,
        "$zip": order.customer.default_address['zip'],
        "$region": order.customer.default_address.province,
        "$country": order.customer.default_address.country_code
      },
      "properties": {
        "$event_id": order.id,
        "$value": order.total_price,
        "OrderId": order.id,
        "ItemNames": order_items(order).map { |item| item[:ProductName] },
        "DiscountCode": order.discount_codes,
        "DiscountValue": order.current_total_discounts,
        "Items": order_items(order),
        "BillingAddress": {
          "$first_name": order.billing_address.first_name,
          "$last_name": order.billing_address.last_name,
          "$phone_number": order.billing_address.phone,
          "$address1": order.billing_address.address1,
          "$address2": order.billing_address.address2,
          "$city": order.billing_address.city,
          "$zip": order.billing_address['zip'],
          "$region": order.billing_address.province,
          "$country": order.billing_address.country_code
        },
        "ShippingAddress": {
          "$first_name": order.shipping_address.first_name,
          "$last_name": order.shipping_address.last_name,
          "$phone_number": order.shipping_address.phone,
          "$address1": order.shipping_address.address1,
          "$address2": order.shipping_address.address2,
          "$city": order.shipping_address.city,
          "$zip": order.shipping_address['zip'],
          "$region": order.shipping_address.province,
          "$country": order.shipping_address.country_code
        }
      },
      "time": DateTime.parse(order.created_at).to_i
    }
  end

  def order_items(order)
    order.line_items.map do |line_item|
      {
        "ProductID": line_item.id,
        "SKU": line_item.sku,
        "ProductName": line_item.name,
        "Quantity": line_item.quantity,
        "ItemPrice": line_item.price
      }
    end
  end

  def since
    params['since']
  end

  def processed_orders

  end

end
