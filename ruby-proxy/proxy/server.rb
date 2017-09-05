# coding: utf-8

INVOICE_QUEUE_NAME = "backend.invoices"
CLIENT_QUEUE_NAME = "backend.clients"

REPLY_TO_CLIENT = "proxy.client.responses"
REPLY_TO_INVOICE = "proxy.invoice.responses"

include QueueDing

INVOICE_RESPONSE_QUEUE = QDing.new
CLIENT_RESPONSE_QUEUE = QDing.new

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

# this never returns
def client_responses!
  channel.queue(REPLY_TO_CLIENT).subscribe do |delivery_info, properties, payload|
    CLIENT_RESPONSE_QUEUE << payload
  end
end

# this never returns
def invoice_responses!
  channel.queue(REPLY_TO_INVOICE).subscribe do |delivery_info, properties, payload|
    INVOICE_RESPONSE_QUEUE << payload
  end
end

def get_clients
  payload = {}.to_json
  exchange.publish(payload,
                   routing_key: CLIENT_QUEUE_NAME,
                   reply_to: REPLY_TO_CLIENT)
  CLIENT_RESPONSE_QUEUE.next
end

def get_invoices(id)
  payload = { client_id: id }.to_json
  exchange.publish(payload,
                   routing_key: INVOICE_QUEUE_NAME,
                   reply_to: REPLY_TO_INVOICE)
  INVOICE_RESPONSE_QUEUE.next
end

get '/clients.json' do
  get_clients
end

get '/invoices.json/:client_id' do
  get_invoices(params['client_id'])
end
