require 'logger'

require_relative '../lib/todoist/todoist_helper'

class BudgetExpenseManager

  BUDGET_EXPENSE_SYMBOLS = ['$', '€', '₴', '₽'].freeze
  BUDGET_EXPENSE_LABEL = 'Budget Expense'

  def initialize
    @todoist_helper = TodoistHelper.new
    @logger = Logger.new(STDOUT)
  end

  def process_budget_expense(message)
    task = @todoist_helper.get_task_by_label(BUDGET_EXPENSE_LABEL)
    @logger.info("Budget expense task exists: #{task['id']}") if task
    # todo:
    # if task exists => add comment to a task with message info
    # if task does not exist => create a task + add a comment to a task with message info
  end

  private

  def is_budget_expense?(data)
    BUDGET_EXPENSE_SYMBOLS.include?(data[:content][0])
  end
end