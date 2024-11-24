require_relative '../lib/telegram/telegram_extractor'
require_relative '../lib/todoist/todoist_client'
require_relative '../bin/budget_expense_manager'

class BotManager

  MAX_CONTENT_LENGTH = 95

  def initialize
    @telegram_extractor = TelegramExtractor.new
    @todoist = TodoistClient.new
    @budget_manager = BudgetExpenseManager.new
  end

  def process_message(message)
    telegram_data = @telegram_extractor.extract_data(message)
    return if telegram_data.nil?

    options = build_todoist_options(telegram_data)

    return @budget_manager.process_budget_expense(options) if @budget_manager.is_budget_expense?(options)
    return shorten(options) if options[:content].length > MAX_CONTENT_LENGTH
    @todoist.create_task(options)
  end

  private

  def shorten(options)
    full_content = options[:content]
    options[:content] = options[:content][0..MAX_CONTENT_LENGTH - 1].concat('...')
    task_id = @todoist.create_task(options)

    comment_options = {
      task_id: task_id,
      content: full_content
    }
    @todoist.add_comment(comment_options)
  end

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