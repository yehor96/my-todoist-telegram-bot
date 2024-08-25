require 'telegram/bot'
require 'net/http'
require 'uri'
require 'json'

require_relative '../lib/configurator'
require_relative '../lib/todoist_client'
require_relative '../lib/telegram_extractor'

config = Configurator.load
todoist = TodoistClient.new
extractor = TelegramExtractor.new

bot = Telegram::Bot::Client.new(config['telegram_token'])
bot.listen do |message|
  options = {
      content: extractor.extract_message(message),
      description: extractor.extract_sender(message),
      labels: ["Telegram"]
  }
  todoist.create_task(options) if options[:content]
end