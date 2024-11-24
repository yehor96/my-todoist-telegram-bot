require 'telegram/bot'

require_relative '../bin/configurator'
require_relative '../bin/bot_manager'

config = Configurator.load
bot_manager = BotManager.new

bot = Telegram::Bot::Client.new(config['telegram_token'])
bot.listen do |message|
  begin
    needs_warning = bot_manager.process_message(message)
    response = needs_warning ? "⚠️ Media files are not supported. Task created without attachments." : "✅ Todoist task created"
    bot.api.send_message(chat_id: message.chat.id, text: response)
  rescue StandardError => e
    bot.api.send_message(chat_id: message.chat.id, text: "❌ Failed to create Todoist task")
    logger.error("Error processing message: #{e.message}")
    nil
  end
end