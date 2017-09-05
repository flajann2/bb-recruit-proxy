class Server

  INVOICE_QUEUE_NAME = "backend.invoices"
  CLIENT_QUEUE_NAME = "backend.clients"


  def self.service(ch = nil)
    @service ||= Server.new(ch)
  end

  private

  def initialize(ch)
    raise "ch must not be nil" if ch.nil?
    @ch = ch
  end
end

get '/clients.json' do
  'clients called'
end

get '/invoices.json' do
  'invoice called'
end
