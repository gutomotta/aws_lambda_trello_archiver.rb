# Source: https://github.com/gutomotta/aws_lambda_trello_archiver.rb

require 'time'
require 'json'

def main(event:, context:)
  api_key = ENV.fetch('TRELLO_API_KEY')
  api_token = ENV.fetch('TRELLO_API_TOKEN')
  board_id = ENV.fetch('TRELLO_BOARD_ID')
  list_name = ENV.fetch('TRELLO_LIST_NAME')
  old_cards_threshold = ENV.fetch('TRELLO_OLD_CARDS_THRESHOLD_DAYS', 2).to_i

  TrelloAPI.setup do |config|
    config.key = api_key
    config.token = api_token
  end

  list = find_list_by_name(board_id, list_name)
  list_old_cards(list['id'], old_cards_threshold).each do |card|
    archive_card(card['id'])
  end
end

def find_list_by_name(board_id, list_name)
  board_lists(board_id).find do |list|
    list['name'].downcase == list_name.to_s.downcase
  end
end

def board_lists(board_id)
  TrelloAPI.get("/boards/#{board_id}/lists", query: {
    fields: 'id,name'
  })
end

def list_old_cards(list_id, threshold_days)
  list_cards(list_id).select do |card|
    threshold_seconds = threshold_days * 24 * 60 * 60
    Time.parse(card['dateLastActivity']) + threshold_seconds < Time.now
  end
end

def list_cards(list_id)
  TrelloAPI.get("/lists/#{list_id}/cards", query: {
    fields: 'id,dateLastActivity'
  })
end

def archive_card(card_id)
  TrelloAPI.put("/cards/#{card_id}", form: { closed: true })
end


class TrelloAPI
  BASE_URL = 'https://api.trello.com/1'

  def self.setup
    @config ||= Struct.new(:key, :token).new
    yield(@config)
  end

  def self.key
    @config.key
  end

  def self.token
    @config.token
  end

  def self.get(endpoint, query: {}, form: {})
    new(endpoint, query: query, form: form).get
  end

  def self.put(endpoint, query: {}, form: {})
    new(endpoint, query: query, form: form).put
  end

  def initialize(endpoint, query: {}, form: {})
    @endpoint = endpoint
    @query = query.merge(key: self.class.key, token: self.class.token)
    @form = form
  end

  def get
    request { https.get(uri.request_uri) }
  end

  def put
    request do
      req = Net::HTTP::Put.new(uri)
      req.set_form_data(@form)
      https.request(req)
    end
  end

  private

  def request
    JSON.parse(yield.body)
  end

  def uri
    return @uri if @uri

    uri = URI.parse("#{BASE_URL}#{@endpoint}")
    uri.query = @query.map { |entry| entry.join('=') }.join('&')

    @uri = uri
  end

  def https
    return @https if @https

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    @https = https
  end
end
