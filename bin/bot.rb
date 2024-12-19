require 'telegram/bot'
require 'dotenv/load'

require_relative '../bin/bot_manager'

logger = Logger.new(STDOUT)

telegram_extractor = TelegramExtractor.new

todoist_client = TodoistClient.new(logger)
todoist_service = TodoistService.new(todoist_client)

budget_service = BudgetService.new(logger, todoist_service, todoist_client)

bot_manager = BotManager.new(telegram_extractor, todoist_client, todoist_service, budget_service)
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