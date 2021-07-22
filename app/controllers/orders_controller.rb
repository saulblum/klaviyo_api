require 'net/http'

class OrdersController < ApplicationController

  SHOPIFY_BASE_URL = 'https://reallyuniquestore.myshopify.com'.freeze

  def sync
    render json: { "orders": update_klaviyo }
  end

  def shopify_orders
    url = "#{SHOPIFY_BASE_URL}/admin/api/2021-07/orders.json?status=any&financial_status=paid"
    url << "&created_at_min=#{since}" if since
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req.basic_auth ENV['SHOPIFY_API_KEY'], ENV['SHOPIFY_API_PASSWORD']

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }

    JSON.parse(res.body)['orders']
  end

  def update_klaviyo
    shopify_orders.map { |order| order['id'] }
  end

  def since
    params['since']
  end

end
