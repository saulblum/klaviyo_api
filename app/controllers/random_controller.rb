require 'net/http'

class RandomController < ApplicationController

  KLAVIYO_TRACK_URL = 'https://a.klaviyo.com/api/track'.freeze
  CUSTOMERS = [
    {
      "email": "mike@smith.com",
      "fname": "Mike",
      "lname": "Smith",
      "address": "123 Main Street",
      "city": "Boston",
      "state": "MA",
      "zip": "02215"
    },
    {
      "email": "dan@johnson.com",
      "fname": "Dan",
      "lname": "Johnson",
      "address": "987 Any Way",
      "city": "Brooklyn",
      "state": "NY",
      "zip": "11234"
    },
    {
      "email": "mstone@gmail.com",
      "fname": "Michelle",
      "lname": "Stone",
      "address": "456 Broadway",
      "city": "New York",
      "state": "NY",
      "zip": "10003"
    },
    {
      "email": "apotter@gmail.com",
      "fname": "Amy",
      "lname": "Potter",
      "address": "1 El Camino Real",
      "city": "San Mateo",
      "state": "CA",
      "zip": "90210"
    },
    {
      "email": "saul@gmail.com",
      "fname": "Saul",
      "lname": "Blumenthal",
      "address": "125 Summer St",
      "city": "Boston",
      "state": "MA",
      "zip": "02111"
    }
  ].freeze

  PRODUCTS = [
    {
      "ProductID": "moon",
      "SKU": 123,
      "ProductName": "Moonrise over the Charles River",
      "ItemPrice": 99.95
    },
    {
      "ProductID": "sun",
      "SKU": 456,
      "ProductName": "Florida sunrise",
      "ItemPrice": 49.95
    },
    {
      "ProductID": "snow",
      "SKU": 789,
      "ProductName": "Blizzard",
      "ItemPrice": 109.95
    },
    {
      "ProductID": "water",
      "SKU": 1234567,
      "ProductName": "Waves",
      "ItemPrice": 89.95
    }
  ].freeze

  def sync
    count = params['count'] || 10
    count.to_i.times do |n|
      customer = CUSTOMERS[rand(0..CUSTOMERS.length-1)]
      placed_order = rand(0..1) == 0
      event = placed_order ? "Placed Order" : "Started Checkout"

      now = Time.now.to_i
      month_ago = (Time.now - 2592000).to_i
      order_date = Time.at(rand(month_ago..now))

      num_products = rand(1..3)
      line_items = []
      order_price = 0
      num_products.times do |p|
        product = PRODUCTS[rand(0..PRODUCTS.length-1)]
        quantity = rand(1..5)
        line_items << {
          "ProductID": product[:ProductID],
          "SKU": product[:ProductID],
          "ProductName": product[:ProductID],
          "Quantity": quantity,
          "ItemPrice": product[:ItemPrice]
        }
        order_price = order_price + (quantity * product[:ItemPrice])
      end

      product_body =
        {
          "token": ENV['KLAVIYO_PUBLIC_KEY'],
          "event": event,
          "customer_properties": {
            "$email": customer[:email],
            "$first_name": customer[:fname],
            "$last_name": customer[:lname],
            "$address1": customer[:address],
            "$city": customer[:city],
            "$region": customer[:state],
            "$zip": customer[:zip]
          },
          "properties": {
            "$event_id": rand(100000..999999).to_s,
            "$value": order_price,
            "ItemNames": line_items.map { |item| item[:ProductName] },
            "Items": line_items
          },
          "time": order_date
        }

      call_klaviyo_track_api(product_body)
    end

    render json: { "number_processed": count }
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

end
