require 'logger'

require_relative '../lib/todoist/todoist_service'
require_relative '../lib/todoist/todoist_client'

class BudgetService

  BUDGET_EXPENSE_SYMBOLS = ['$', '€', '₴', '₽', '¥', '£'].freeze
  BUDGET_EXPENSE_LABEL = 'Budget Expense'

  def initialize(logger, todoist_service, todoist_client)
    @logger = logger
    @todoist_service = todoist_service
    @todoist = todoist_client
  end

  def process_budget_expense(options)
    task_id = get_budget_expense_task(options)
    strip_budget_expense_symbol(options)
    @todoist_service.add_comment(task_id, options[:content])
  end

  def is_budget_expense?(data)
    BUDGET_EXPENSE_SYMBOLS.include?(data[:content][0])
  end

  private

  def strip_budget_expense_symbol(data)
    data[:content].slice!(0)
  end

  def get_budget_expense_task(options)
    tasks = @todoist_service.get_tasks_by_label(BUDGET_EXPENSE_LABEL)
    return tasks[0]['id'] if !tasks.nil? && tasks.length > 0

    budget_expense_options = {
      content: 'Current week expenses',
      description: options[:description],
      labels: [
        BUDGET_EXPENSE_LABEL,
      ]
    }
    budget_expense_options[:labels].concat(options[:labels])

    return @todoist.create_task(budget_expense_options)
  end
end