# coding: utf-8

INVOICE_QUEUE_NAME = "backend.invoices"
CLIENT_QUEUE_NAME = "backend.clients"

enable :sessions

def connection
  unless $connection
    $connection = Bunny.new("amqp://#{PROXY_USER}:#{PROXY_PASSWORD}@#{PROXY_HOST}:#{PROXY_PORT}")
    $connection.start
  end
  $connection
end

def channel
  $channel = connection.create_channel unless $channel
  $channel
end

def exchange
  unless $exchange
    $exchange = channel.default_exchange
  end
  $exchange
end

def get_clients
  payload = {}.to_json
  exchange.publish(payload, routing_key: CLIENT_QUEUE_NAME)
end

def get_invoices(id)
  payload = { client_id: id }.to_json
  exchange.publish(payload, routing_key: INVOICE_QUEUE_NAME)
end


get '/clients.json' do
  get_clients
end

get '/invoices.json/:client_id' do
  get_invoices(params['client_id'])
end
