require_relative '../lib/telegram/telegram_extractor'
require_relative '../lib/todoist/todoist_client'
require_relative '../bin/budget_expense_manager'

class BotManager

  def initialize
    @telegram_extractor = TelegramExtractor.new
    @todoist = TodoistClient.new
    @budget_manager = BudgetExpenseManager.new
  end

  def process_message(message)
    telegram_data = @telegram_extractor.extract_data(message)
    return if telegram_data.nil?

    options = build_todoist_options(telegram_data)

    @budget_manager.is_budget_expense?(options) ? @budget_manager.process_budget_expense(options) : @todoist.create_task(options)
  end

  private

  def build_todoist_options(telegram_data)
    {
      content: telegram_data[:text],
      description: telegram_data[:sender],
      labels: [
        'Telegram',
      ]
    }
  end
end