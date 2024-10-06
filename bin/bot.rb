require 'telegram/bot'

require_relative '../bin/configurator'
require_relative '../bin/bot_manager'

config = Configurator.load
bot_manager = BotManager.new

bot = Telegram::Bot::Client.new(config['telegram_token'])
bot.listen do |message|
  bot_manager.process_message(message)
end