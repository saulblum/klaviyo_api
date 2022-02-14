require 'net/http'

class SyncController < ActionController::API

  KLAVIYO_TRACK_URL = 'https://a.klaviyo.com/api/track'.freeze

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
    contacts = JSON.parse(File.read('app/controllers/contacts.json'))

    count = (params['since'] ? (Time.now - Time.parse(params['since'])) / 86400 : 10) * rand(1..5)
    count.to_i.times do |n|
      customer = Hashie::Mash.new(contacts[rand(0..contacts.length-1)])
      placed_order = rand(0..1) == 0
      event = placed_order ? "Placed Order" : "Started Checkout"

      now = Time.now.to_i
      since_date = params['since'] ? Time.parse(params['since']).to_i : now - 864000
      order_date = Time.at(rand(since_date..now))

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
            "$first_name": customer[:first_name],
            "$last_name": customer[:last_name],
            "$address1": customer[:address],
            "$city": customer[:city],
            "$region": customer[:state],
            "$zip": customer[:zip],
            "$phone_number": customer[:phone],
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

    render json: { "number_processed": count.to_i }
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
