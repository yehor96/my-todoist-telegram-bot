require 'telegram/bot'
require 'net/http'
require 'uri'
require 'json'
require 'date'

require_relative '../bin/configurator'
require_relative '../lib/todoist/todoist_client'
require_relative '../lib/telegram/telegram_extractor'

config = Configurator.load
todoist = TodoistClient.new
telegram_extractor = TelegramExtractor.new

bot = Telegram::Bot::Client.new(config['telegram_token'])
bot.listen do |message|
  data = telegram_extractor.extract_message_data(message)
  todoist.create_task(data) unless data.nil?
end