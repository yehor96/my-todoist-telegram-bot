require 'telegram/bot'
require 'dotenv/load'

require_relative '../bin/bot_manager'

bot_manager = BotManager.new

bot = Telegram::Bot::Client.new(ENV['TELEGRAM_TOKEN'])
bot.listen do |message|
  begin
    bot_manager.process_message(message)
    response = bot_manager.needs_warning?(message) ? "⚠️ Media files are not supported. Task created without attachments." : "✅ Todoist task created"
    bot.api.send_message(chat_id: message.chat.id, text: response)
  rescue StandardError => e
    bot.api.send_message(chat_id: message.chat.id, text: "❌ Failed to create Todoist task")
    logger.error("Error processing message: #{e.message}")
    nil
  end
end