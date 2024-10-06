require_relative '../lib/telegram/telegram_extractor'
require_relative '../lib/todoist/todoist_client'
require_relative '../bin/budget_expense_manager'

class BotManager

  def initialize
    @telegram_extractor = TelegramExtractor.new
    @todoist = TodoistClient.new
    @budget_expense_manager = BudgetExpenseManager.new
  end

  def process_message(message)
    telegram_data = @telegram_extractor.extract_message_data(message)
    return if telegram_data.nil?

    options = build_todoist_options(telegram_data)

    @budget_expense_manager.process_budget_expense(options)
    @todoist.create_task(options)
  end

  private

  def build_todoist_options(telegram_data)
    {
      content: telegram_data[:text],
      description: Time.now.strftime("%b %-d, %Y %H:%M"),
      labels: [
        'Telegram',
        telegram_data[:sender]
      ]
    }
  end
end