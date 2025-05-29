require_relative '../lib/telegram/telegram_extractor'
require_relative '../lib/todoist/todoist_client'
require_relative '../lib/todoist/todoist_service'
require_relative '../bin/budget_service'
require_relative '../errors/forbidden_error'
require_relative '../utils/file_reader'

class BotManager
  MAX_CONTENT_LENGTH = 95

  def initialize(telegram_extractor, todoist_client, todoist_service, budget_service, validator)
    @telegram_extractor = telegram_extractor
    @todoist = todoist_client
    @todoist_service = todoist_service
    @budget_service = budget_service
    @validator = validator
  end

  def process_message(message)
    telegram_data = @telegram_extractor.extract_data(message)
    return if telegram_data.nil?
    @validator.validate_user_allowed(telegram_data[:username])

    options = build_todoist_options(telegram_data)

    return @budget_service.process_budget_expense(options) if @budget_service.is_budget_expense?(options)

    shorten(options) if options[:content].length > MAX_CONTENT_LENGTH

    task_id = @todoist.create_task(options)
    process_comments(task_id, options) if options[:comments].length > 0
  end

  def needs_warning?(message)
    message.photo || message.video || message.document || message.audio || message.voice
  end

  private

  def process_comments(task_id, options)
    options[:comments].each do |comment|
      @todoist_service.add_comment(task_id, comment)
    end
  end

  def shorten(options)
    full_content = options[:content]
    options[:content] = options[:content][0..MAX_CONTENT_LENGTH - 1].concat('...')
    options[:comments].unshift(full_content)
  end

  def build_todoist_options(telegram_data)
    {
      content: telegram_data[:text],
      description: telegram_data[:sender],
      comments: telegram_data[:links],
      labels: [
        'Telegram',
      ]
    }
  end
end