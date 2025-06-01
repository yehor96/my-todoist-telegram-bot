require_relative '../lib/telegram/telegram_extractor'
require_relative '../lib/todoist/todoist_client'
require_relative '../lib/todoist/todoist_service'
require_relative '../bin/budget_service'
require_relative '../errors/forbidden_error'
require_relative '../utils/file_reader'

class BotManager
  MAX_TITLE_LENGTH = 95
  CUSTOM_TITLE_SYMBOL = '!'

  def initialize(telegram_extractor, todoist_client, todoist_service, budget_service, validator)
    @telegram_extractor = telegram_extractor
    @todoist = todoist_client
    @todoist_service = todoist_service
    @budget_service = budget_service
    @validator = validator
  end

  # returns true if message was processed, false otherwise
  def process_message(message)
    data = @telegram_extractor.extract_data(message)
    return false if data.nil?
    @validator.validate_user_allowed(data[:sender])

    if @budget_service.is_budget_expense?(data) 
      @budget_service.process_budget_expense(data)
      return true
    end

    return false if process_custom_title(data)
    shorten_title(data) if data[:title].length > MAX_TITLE_LENGTH

    options = build_todoist_options(data)
    task_id = @todoist.create_task(options)
    process_comments(task_id, options) if options[:comments].length > 0
    return true
  end

  def needs_warning?(message)
    message.photo || message.video || message.document || message.audio || message.voice
  end

  private

  def build_todoist_options(data)
    {
      content: data[:title],
      description: data[:author],
      comments: data[:additions],
      labels: data[:labels]
    }
  end

  def process_custom_title(data)
    if data[:title][0] == CUSTOM_TITLE_SYMBOL
      data[:title].slice!(0).strip!
      @custom_title = data[:title]
      @custom_title_timestamp = data[:timestamp]

      return true
    elsif @custom_title
      if @custom_title_timestamp == data[:timestamp]
        data[:additions].unshift(data[:title])
        data[:title] = @custom_title
      end
      @custom_title = nil
      @custom_title_timestamp = nil
    end

    return false
  end

  def shorten_title(data)
    full_title = data[:title]
    data[:title] = data[:title][0..MAX_TITLE_LENGTH - 1].concat('...')
    data[:additions].unshift(full_title)
  end

  def process_comments(task_id, options)
    options[:comments].each do |comment|
      @todoist_service.add_comment(task_id, comment)
    end
  end
end